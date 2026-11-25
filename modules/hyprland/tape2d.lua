-- tape2d: horizontal columns, each column scrolls vertically on its own.
-- Windows in a column are half the work area tall (full height when alone),
-- so a column with 3+ windows overflows and scrolls.
--
-- layout messages (hl.dsp.layout("...")):
--   focusleft / focusright      move focus between columns, clamps at the edge
--   focusup / focusdown         move focus inside the column, clamps at the edge
--   moveleft / moveright        single-window column joins the neighbor,
--                               otherwise split off into a new column
--   moveup / movedown           reorder the window inside its column
--   grow / shrink / width <f>   resize the focused column
--   taller / shorter           resize the focused window vertically
--   reset                       restore default widths/offsets/heights

local DEFAULT_WIDTH = 0.5
local MIN_WIDTH = 0.2
local WIDTH_STEP = 0.1
local HEIGHT_STEP = 0.1

local STATE = {}

local function clamp(value, low, high)
  return math.max(low, math.min(high, value))
end

local function target_id(target)
  local window = target.window
  if window then return tostring(window.stable_id) end
  return "index:" .. tostring(target.index)
end

local function workspace_id(ctx)
  for _, target in ipairs(ctx.targets) do
    local window = target.window
    if window and window.workspace then return window.workspace.id end
  end
  return "unknown"
end

local function state_for(ctx)
  local id = workspace_id(ctx)
  local state = STATE[id]
  if not state then
    state = { columns = {}, offset = 0, focus = nil, heights = {} }
    STATE[id] = state
  end
  return state
end

local function locate(state, id)
  for column_index, column in ipairs(state.columns) do
    for row_index, entry in ipairs(column.targets) do
      if entry == id then return column_index, row_index end
    end
  end
end

local function active_target(ctx)
  for _, target in ipairs(ctx.targets) do
    local window = target.window
    if window and window.active then return target end
  end
end

local function sync(state, ctx)
  local present = {}
  for _, target in ipairs(ctx.targets) do present[target_id(target)] = target end

  for column_index = #state.columns, 1, -1 do
    local column = state.columns[column_index]
    for row_index = #column.targets, 1, -1 do
      if not present[column.targets[row_index]] then
        state.heights[column.targets[row_index]] = nil
        table.remove(column.targets, row_index)
      end
    end
    if #column.targets == 0 then table.remove(state.columns, column_index) end
  end

  local active = active_target(ctx)
  local active_id = active and target_id(active)

  local active_column = active_id and locate(state, active_id)
  local insert_at = active_column and (active_column + 1) or (#state.columns + 1)

  for _, target in ipairs(ctx.targets) do
    local id = target_id(target)
    if not locate(state, id) then
      table.insert(state.columns, insert_at, { width = DEFAULT_WIDTH, scroll = 0, targets = { id } })
      insert_at = insert_at + 1
    end
  end

  if #state.columns == 0 then
    table.insert(state.columns, { width = DEFAULT_WIDTH, scroll = 0, targets = {} })
  end

  return present
end

local function place(ctx, state, present)
  local area = ctx.area
  local total_width = 0
  for _, column in ipairs(state.columns) do total_width = total_width + area.w * column.width end

  local active = active_target(ctx)
  local active_id = active and target_id(active)
  local active_column, active_row
  if active_id then active_column, active_row = locate(state, active_id) end

  local focus_changed = active_id ~= state.focus
  state.focus = active_id

  if focus_changed and active_column then
    local x = 0
    for index = 1, active_column - 1 do x = x + area.w * state.columns[index].width end
    local width = area.w * state.columns[active_column].width
    if x < state.offset then state.offset = x end
    if x + width > state.offset + area.w then state.offset = x + width - area.w end
  end
  state.offset = clamp(state.offset, 0, math.max(0, total_width - area.w))

  local x = area.x - state.offset
  for column_index, column in ipairs(state.columns) do
    local width = area.w * column.width
    local count = math.max(#column.targets, 1)
    local default_fraction = 1 / math.min(count, 2)

    local heights, total = {}, 0
    for row_index, id in ipairs(column.targets) do
      heights[row_index] = area.h * (state.heights[id] or default_fraction)
      total = total + heights[row_index]
    end
    local max_scroll = math.max(0, total - area.h)

    if focus_changed and column_index == active_column and active_row then
      local top = 0
      for index = 1, active_row - 1 do top = top + heights[index] end
      local bottom = top + heights[active_row]
      if top < column.scroll then column.scroll = top end
      if bottom > column.scroll + area.h then column.scroll = bottom - area.h end
    end

    column.scroll = clamp(column.scroll, 0, max_scroll)

    local y = area.y - column.scroll
    for row_index, id in ipairs(column.targets) do
      local target = present[id]
      if target then
        target:place({ x = x, y = y, w = width, h = heights[row_index] })
      end
      y = y + heights[row_index]
    end

    x = x + width
  end
end

local function focused(state, ctx)
  local active = active_target(ctx)
  if active then
    local column_index, row_index = locate(state, target_id(active))
    if column_index then return column_index, row_index end
  end
  return 1, nil
end

local function move_horizontal(state, ctx, direction)
  local active = active_target(ctx)
  if not active then return end

  local column_index, row_index = locate(state, target_id(active))
  if not column_index then return end

  local column = state.columns[column_index]
  local step = direction == "left" and -1 or 1
  local id = target_id(active)

  if #column.targets > 1 then
    table.remove(column.targets, row_index)
    local insert_at = step < 0 and column_index or column_index + 1
    table.insert(state.columns, insert_at, { width = column.width, scroll = 0, targets = { id } })
    return
  end

  local neighbor = state.columns[column_index + step]
  if neighbor then
    table.remove(column.targets, row_index)
    table.insert(neighbor.targets, id)
  end
end

local function move_vertical(state, ctx, direction)
  local active = active_target(ctx)
  if not active then return end

  local column_index, row_index = locate(state, target_id(active))
  if not column_index then return end

  local column = state.columns[column_index]
  local swap_with = row_index + (direction == "up" and -1 or 1)
  if swap_with < 1 or swap_with > #column.targets then return end

  column.targets[row_index], column.targets[swap_with] = column.targets[swap_with], column.targets[row_index]
end

local function adjust_height(state, ctx, delta)
  local active = active_target(ctx)
  if not active then return end

  local column_index, _ = locate(state, target_id(active))
  if not column_index then return end

  local count = math.max(#state.columns[column_index].targets, 1)
  local id = target_id(active)
  local current = state.heights[id] or (1 / math.min(count, 2))

  state.heights[id] = clamp(current + delta, 0.15, 1)
end

local function target_for(ctx, id)
  for _, target in ipairs(ctx.targets) do
    if target_id(target) == id then return target end
  end
end

local function focus_in_direction(state, ctx, direction)
  local active = active_target(ctx)
  if not active then return end

  local column_index, row_index = locate(state, target_id(active))
  if not column_index then return end

  if direction == "up" or direction == "down" then
    row_index = row_index + (direction == "up" and -1 or 1)
    if row_index < 1 or row_index > #state.columns[column_index].targets then return end
  else
    column_index = column_index + (direction == "left" and -1 or 1)
    local column = state.columns[column_index]
    if not column then return end
    row_index = math.min(row_index, #column.targets)
  end

  local column = state.columns[column_index]
  local target = column and target_for(ctx, column.targets[row_index])
  if not target or not target.window then return end

  hl.dispatch(hl.dsp.focus({ window = "address:" .. target.window.address }))
end

hl.layout.register("tape2d", {
  recalculate = function(ctx)
    if #ctx.targets == 0 then return end
    local state = state_for(ctx)
    local present = sync(state, ctx)
    place(ctx, state, present)
  end,

  layout_msg = function(ctx, msg)
    if #ctx.targets == 0 then return true end

    local state = state_for(ctx)
    local present = sync(state, ctx)
    local command, argument = msg:match("^(%S+)%s*(.*)$")
    local column_index = focused(state, ctx)
    local column = state.columns[column_index]

    if command == "follow" then
      -- relayout only; place() below scrolls the active window into view
    elseif command == "focusleft" then
      focus_in_direction(state, ctx, "left")
      return true
    elseif command == "focusright" then
      focus_in_direction(state, ctx, "right")
      return true
    elseif command == "focusup" then
      focus_in_direction(state, ctx, "up")
      return true
    elseif command == "focusdown" then
      focus_in_direction(state, ctx, "down")
      return true
    elseif command == "moveleft" then
      move_horizontal(state, ctx, "left")
      present = sync(state, ctx)
    elseif command == "moveright" then
      move_horizontal(state, ctx, "right")
      present = sync(state, ctx)
    elseif command == "moveup" then
      move_vertical(state, ctx, "up")
    elseif command == "movedown" then
      move_vertical(state, ctx, "down")
    elseif command == "grow" then
      column.width = clamp(column.width + WIDTH_STEP, MIN_WIDTH, 1)
    elseif command == "shrink" then
      column.width = clamp(column.width - WIDTH_STEP, MIN_WIDTH, 1)
    elseif command == "taller" then
      adjust_height(state, ctx, HEIGHT_STEP)
    elseif command == "shorter" then
      adjust_height(state, ctx, -HEIGHT_STEP)
    elseif command == "width" then
      column.width = clamp(tonumber(argument) or column.width, MIN_WIDTH, 1)
    elseif command == "reset" then
      state.offset = 0
      state.heights = {}
      for _, entry in ipairs(state.columns) do
        entry.width = DEFAULT_WIDTH
        entry.scroll = 0
      end
    else
      return "tape2d: expected moveleft|moveright|moveup|movedown|grow|shrink|taller|shorter|width <f>|reset"
    end

    state.focus = nil
    place(ctx, state, present)
    return true
  end,
})

hl.on("window.active", function(window)
  if not window then return end
  hl.dispatch(hl.dsp.layout("follow"))
end)

