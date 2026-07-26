#!/usr/bin/env bats

setup() {
  RESOLVE="${BATS_TEST_DIRNAME}/../scripts/resolve_asset.sh"
}

@test "Linux X64 resolves to x86_64-linux tarball" {
  run "$RESOLVE" Linux X64
  [ "$status" -eq 0 ]
  [ "$output" = "bqvalid-x86_64-linux.tar.gz" ]
}

@test "macOS X64 resolves to x86_64-darwin tarball" {
  run "$RESOLVE" macOS X64
  [ "$status" -eq 0 ]
  [ "$output" = "bqvalid-x86_64-darwin.tar.gz" ]
}

@test "macOS ARM64 resolves to arm64-darwin tarball" {
  run "$RESOLVE" macOS ARM64
  [ "$status" -eq 0 ]
  [ "$output" = "bqvalid-arm64-darwin.tar.gz" ]
}

@test "Windows X64 resolves to x86_64-windows zip" {
  run "$RESOLVE" Windows X64
  [ "$status" -eq 0 ]
  [ "$output" = "bqvalid-x86_64-windows.zip" ]
}

@test "Linux ARM64 is unsupported and fails" {
  run "$RESOLVE" Linux ARM64
  [ "$status" -ne 0 ]
  [[ "$output" == *"unsupported"* ]]
}

@test "unknown OS is unsupported and fails" {
  run "$RESOLVE" Solaris X64
  [ "$status" -ne 0 ]
  [[ "$output" == *"unsupported"* ]]
}

@test "missing arguments fail" {
  run "$RESOLVE" Linux
  [ "$status" -ne 0 ]
}
