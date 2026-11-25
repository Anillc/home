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
--   zoom                        fill the viewport, keeping the tape margins
--   taller / shorter           resize the focused window vertically
--   reset                       restore default widths/offsets/heights

local DEFAULT_WIDTH = 0.5
local MIN_WIDTH = 0.2
local WIDTH_STEP = 0.1
local MARGIN = 10
local MARGIN_V = 10
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
    state = { columns = {}, offset = 0, focus = nil, heights = {}, zoom = {}, floating = {} }
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

local function column_index_of(state, id)
  for column_index, column in ipairs(state.columns) do
    for _, entry in ipairs(column.targets) do
      if entry == id then return column_index end
    end
  end
end

local function insert_restored(state, id, saved)
  local anchor_column = saved.column_anchor and column_index_of(state, saved.column_anchor)
  if anchor_column then
    local column = state.columns[anchor_column]
    local row = clamp(saved.row, 1, #column.targets + 1)
    table.insert(column.targets, row, id)
    if saved.height ~= nil then state.heights[id] = saved.height end
    return
  end

  local index
  if saved.prev_anchor then
    local prev = column_index_of(state, saved.prev_anchor)
    if prev then index = prev + 1 end
  end
  if not index and saved.next_anchor then
    index = column_index_of(state, saved.next_anchor)
  end
  index = index or clamp(saved.column, 1, #state.columns + 1)

  table.insert(state.columns, index, { width = saved.width, auto = saved.auto, scroll = 0, targets = { id } })
  if saved.height ~= nil then state.heights[id] = saved.height end
end

local function sync(state, ctx)
  local present = {}
  for _, target in ipairs(ctx.targets) do present[target_id(target)] = target end

  for column_index = #state.columns, 1, -1 do
    local column = state.columns[column_index]
    for row_index = #column.targets, 1, -1 do
      local id = column.targets[row_index]
      if not present[id] then
        local column_anchor
        for _, other in ipairs(column.targets) do
          if other ~= id then
            column_anchor = other
            break
          end
        end

        state.floating[id] = {
          row = row_index,
          column = column_index,
          width = column.width,
          auto = column.auto,
          height = state.heights[id],
          column_anchor = column_anchor,
          prev_anchor = state.columns[column_index - 1] and state.columns[column_index - 1].targets[1],
          next_anchor = state.columns[column_index + 1] and state.columns[column_index + 1].targets[1],
        }

        state.heights[id] = nil
        state.zoom[id] = nil
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
      local saved = state.floating[id]
      if saved then
        state.floating[id] = nil
        insert_restored(state, id, saved)
      else
        local width = #state.columns == 0 and 1.0 or DEFAULT_WIDTH
        table.insert(state.columns, insert_at, { width = width, auto = true, scroll = 0, targets = { id } })
        insert_at = insert_at + 1
      end
    end
  end

  for _, column in ipairs(state.columns) do
    if column.auto then
      column.width = #state.columns == 1 and 1.0 or DEFAULT_WIDTH
    end
  end

  if #state.columns == 0 then
    table.insert(state.columns, { width = DEFAULT_WIDTH, auto = true, scroll = 0, targets = {} })
  end

  return present
end

local function place(ctx, state, present)
  local area = ctx.area
  local view_width = math.max(area.w - 2 * MARGIN, 1)
  local view_height = math.max(area.h - 2 * MARGIN_V, 1)
  local total_width = 0
  for _, column in ipairs(state.columns) do total_width = total_width + view_width * column.width end

  local active = active_target(ctx)
  local active_id = active and target_id(active)
  local active_column, active_row
  if active_id then active_column, active_row = locate(state, active_id) end
  if active_column and active_id then state.columns[active_column].last = active_id end

  local focus_changed = active_id ~= state.focus
  state.focus = active_id

  if focus_changed and active_column then
    local x = 0
    for index = 1, active_column - 1 do x = x + view_width * state.columns[index].width end
    local width = view_width * state.columns[active_column].width
    if x < state.offset then state.offset = x end
    if x + width > state.offset + view_width then state.offset = x + width - view_width end
  end

  state.offset = clamp(state.offset, 0, math.max(0, total_width - view_width))

  local x = area.x + MARGIN - state.offset
  for column_index, column in ipairs(state.columns) do
    local width = view_width * column.width
    local count = math.max(#column.targets, 1)
    local default_fraction = 1 / math.min(count, 2)

    local heights, total = {}, 0
    for row_index, id in ipairs(column.targets) do
      heights[row_index] = view_height * (state.heights[id] or default_fraction)
      total = total + heights[row_index]
    end
    local max_scroll = math.max(0, total - view_height)

    if focus_changed and column_index == active_column and active_row then
      local top = 0
      for index = 1, active_row - 1 do top = top + heights[index] end
      local bottom = top + heights[active_row]
      if top < column.scroll then column.scroll = top end
      if bottom > column.scroll + view_height then column.scroll = bottom - view_height end
    end

    column.scroll = clamp(column.scroll, 0, max_scroll)

    local y = area.y + MARGIN_V - column.scroll
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
    table.insert(state.columns, insert_at, { width = column.width, auto = true, scroll = 0, targets = { id } })
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

local function toggle_zoom(state, ctx)
  local active = active_target(ctx)
  if not active then return end

  local column_index, _ = locate(state, target_id(active))
  if not column_index then return end

  local column = state.columns[column_index]
  local id = target_id(active)
  local saved = state.zoom[id]

  if saved then
    column.width = saved.width
    column.auto = saved.auto
    state.heights[id] = saved.height
    state.zoom[id] = nil
    return
  end

  state.zoom[id] = { width = column.width, height = state.heights[id], auto = column.auto }
  column.auto = false
  column.width = 1.0
  state.heights[id] = 1.0
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

local function row_of(column, id)
  for row_index, entry in ipairs(column.targets) do
    if entry == id then return row_index end
  end
end

local function visible_row(state, ctx, column, preferred)
  local view_height = math.max(ctx.area.h - 2 * MARGIN_V, 1)
  local count = math.max(#column.targets, 1)
  local default_fraction = 1 / math.min(count, 2)

  local best_row, best_visible, best_distance = 1, -1, math.huge
  local top = 0
  for row_index, id in ipairs(column.targets) do
    local height = view_height * (state.heights[id] or default_fraction)
    local visible = math.min(top + height, column.scroll + view_height) - math.max(top, column.scroll)
    if visible < 0 then visible = 0 end
    local distance = math.abs(row_index - (preferred or 1))
    if visible > best_visible + 0.5 or (math.abs(visible - best_visible) <= 0.5 and distance < best_distance) then
      best_row, best_visible, best_distance = row_index, visible, distance
    end
    top = top + height
  end
  return best_row
end

local function focus_in_direction(state, ctx, direction)
  local active = active_target(ctx)
  if not active then
    hl.dispatch(hl.dsp.focus({ direction = direction }))
    return
  end

  local column_index, row_index = locate(state, target_id(active))
  if not column_index then return end

  if direction == "up" or direction == "down" then
    row_index = row_index + (direction == "up" and -1 or 1)
    if row_index < 1 or row_index > #state.columns[column_index].targets then return end
  else
    column_index = column_index + (direction == "left" and -1 or 1)
    local column = state.columns[column_index]
    if not column then return end
    row_index = (column.last and row_of(column, column.last)) or visible_row(state, ctx, column, row_index)
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
    local command, argument = msg:match("^(%S+)%s*(.*)$")

    if #ctx.targets == 0 then
      if command == "focusleft" or command == "focusright" or command == "focusup" or command == "focusdown" then
        hl.dispatch(hl.dsp.focus({ direction = command:sub(6) }))
      end
      return true
    end

    local state = state_for(ctx)
    local present = sync(state, ctx)
    local column_index = focused(state, ctx)
    local column = state.columns[column_index]

    if not active_target(ctx) and
       (command == "grow" or command == "shrink" or command == "width" or command == "zoom" or command == "taller" or command == "shorter") then
      return true
    end

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
      column.auto = false
      column.width = clamp(column.width + WIDTH_STEP, MIN_WIDTH, 1)
    elseif command == "shrink" then
      column.auto = false
      column.width = clamp(column.width - WIDTH_STEP, MIN_WIDTH, 1)
    elseif command == "zoom" then
      toggle_zoom(state, ctx)
    elseif command == "taller" then
      adjust_height(state, ctx, HEIGHT_STEP)
    elseif command == "shorter" then
      adjust_height(state, ctx, -HEIGHT_STEP)
    elseif command == "width" then
      column.auto = false
      column.width = clamp(tonumber(argument) or column.width, MIN_WIDTH, 1)
    elseif command == "reset" then
      state.offset = 0
      state.heights = {}
      state.zoom = {}
      state.floating = {}
      for _, entry in ipairs(state.columns) do
        entry.auto = true
        entry.width = #state.columns == 1 and 1.0 or DEFAULT_WIDTH
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

local monitor_focus = {}

local function on_special(window)
  return window.workspace ~= nil and window.workspace.special
end

local function remember_monitor_focus(window)
  if window and window.monitor and not on_special(window) then
    monitor_focus[window.monitor.name] = window.address
  end
end

function tape2d_focus_monitor(delta)
  local monitors = hl.get_monitors()
  if not monitors or #monitors < 2 then return end

  local current = hl.get_active_monitor()
  local index = 1
  for i, monitor in ipairs(monitors) do
    if current and monitor.name == current.name then index = i end
  end

  local target = monitors[((index - 1 + (delta or 1)) % #monitors) + 1]
  if not target then return end

  local address = monitor_focus[target.name]
  local window = address and hl.get_window("address:" .. address)
  if window and not on_special(window) then
    hl.dispatch(hl.dsp.focus({ window = "address:" .. address }))
  else
    hl.dispatch(hl.dsp.focus({ monitor = target.name }))
  end
end

hl.on("window.destroy", function(window)
  if not window then return end
  local id = tostring(window.stable_id)
  for _, state in pairs(STATE) do
    state.floating[id] = nil
    state.heights[id] = nil
    state.zoom[id] = nil
  end
end)

hl.on("window.active", function(window)
  if not window then return end
  remember_monitor_focus(window)
  hl.dispatch(hl.dsp.layout("follow"))
end)

