#define _GNU_SOURCE

#include <dlfcn.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#define STORE "/nix/store/"
#define OVERFLOW_ID 65534

static void fix(uid_t *uid, gid_t *gid, int dirfd, const char *path) {
  char dir[4096], full[8192];

  if (*uid != OVERFLOW_ID && *gid != OVERFLOW_ID)
    return;

  if (path == nullptr || *path != '/') {
    if (dirfd == AT_FDCWD) {
      if (getcwd(dir, sizeof dir) == nullptr)
        return;
    } else {
      char link[32];
      snprintf(link, sizeof link, "/proc/self/fd/%d", dirfd);
      auto n = readlink(link, dir, sizeof dir - 1);
      if (n < 0)
        return;
      dir[n] = '\0';
    }
    if (path == nullptr || *path == '\0') {
      path = dir;
    } else {
      snprintf(full, sizeof full, "%s/%s", dir, path);
      path = full;
    }
  }

  if (path == nullptr || strncmp(path, STORE, sizeof STORE - 1) != 0)
    return;
  if (*uid == OVERFLOW_ID)
    *uid = 0;
  if (*gid == OVERFLOW_ID)
    *gid = 0;
}

int stat(const char *path, struct stat *st) {
  static int (*real)(const char *, struct stat *);

  if (real == nullptr)
    real = dlsym(RTLD_NEXT, "stat");
  auto ret = real(path, st);
  if (ret == 0)
    fix(&st->st_uid, &st->st_gid, AT_FDCWD, path);
  return ret;
}

int lstat(const char *path, struct stat *st) {
  static int (*real)(const char *, struct stat *);

  if (real == nullptr)
    real = dlsym(RTLD_NEXT, "lstat");
  auto ret = real(path, st);
  if (ret == 0)
    fix(&st->st_uid, &st->st_gid, AT_FDCWD, path);
  return ret;
}

int fstat(int fd, struct stat *st) {
  static int (*real)(int, struct stat *);

  if (real == nullptr)
    real = dlsym(RTLD_NEXT, "fstat");
  auto ret = real(fd, st);
  if (ret == 0)
    fix(&st->st_uid, &st->st_gid, fd, nullptr);
  return ret;
}

int fstatat(int dirfd, const char *path, struct stat *st, int flags) {
  static int (*real)(int, const char *, struct stat *, int);

  if (real == nullptr)
    real = dlsym(RTLD_NEXT, "fstatat");
  auto ret = real(dirfd, path, st, flags);
  if (ret == 0)
    fix(&st->st_uid, &st->st_gid, dirfd, path);
  return ret;
}

int statx(int dirfd, const char *path, int flags, unsigned int mask,
          struct statx *stx) {
  static int (*real)(int, const char *, int, unsigned int, struct statx *);

  if (real == nullptr)
    real = dlsym(RTLD_NEXT, "statx");
  auto ret = real(dirfd, path, flags, mask, stx);
  if (ret == 0)
    fix(&stx->stx_uid, &stx->stx_gid, dirfd, path);
  return ret;
}
