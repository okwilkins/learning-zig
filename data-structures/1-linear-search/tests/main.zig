test "empty slice -> false" {
    const arr = [_]i32{};
    try std.testing.expectEqual(false, linearSearch(arr[0..], 123));
}

test "single element present" {
    const arr = [_]i32{42};
    try std.testing.expectEqual(true, linearSearch(arr[0..], 42));
}

test "single element absent" {
    const arr = [_]i32{42};
    try std.testing.expectEqual(false, linearSearch(arr[0..], -1));
}

test "present at start" {
    const arr = [_]i32{ 5, 7, 9, 11 };
    try std.testing.expectEqual(true, linearSearch(arr[0..], 5));
}

test "present in middle" {
    const arr = [_]i32{ 5, 7, 9, 11 };
    try std.testing.expectEqual(true, linearSearch(arr[0..], 9));
}

test "present at end" {
    const arr = [_]i32{ 5, 7, 9, 11 };
    try std.testing.expectEqual(true, linearSearch(arr[0..], 11));
}

test "absent value" {
    const arr = [_]i32{ 5, 7, 9, 11 };
    try std.testing.expectEqual(false, linearSearch(arr[0..], 4));
}

test "duplicates present returns true" {
    const arr = [_]i32{ 1, 2, 2, 3, 4 };
    try std.testing.expectEqual(true, linearSearch(arr[0..], 2));
}

test "duplicates absent value returns false" {
    const arr = [_]i32{ 1, 2, 2, 3, 4 };
    try std.testing.expectEqual(false, linearSearch(arr[0..], 5));
}

test "negatives and zero" {
    const arr = [_]i32{ -3, 0, -1, 7 };
    try std.testing.expectEqual(true, linearSearch(arr[0..], -1));
    try std.testing.expectEqual(true, linearSearch(arr[0..], 0));
    try std.testing.expectEqual(false, linearSearch(arr[0..], 1));
}

test "min and max i32" {
    const min = std.math.minInt(i32);
    const max = std.math.maxInt(i32);
    const arr = [_]i32{ min, 0, max };
    try std.testing.expectEqual(true, linearSearch(arr[0..], min));
    try std.testing.expectEqual(true, linearSearch(arr[0..], max));
    try std.testing.expectEqual(false, linearSearch(arr[0..], min + 1));
}

test "subslice search" {
    const arr = [_]i32{ 10, 20, 30, 40, 50 };
    const mid = arr[1..4]; // {20, 30, 40}
    try std.testing.expectEqual(true, linearSearch(mid, 20));
    try std.testing.expectEqual(true, linearSearch(mid, 40));
    try std.testing.expectEqual(false, linearSearch(mid, 50));
}

test "repeated needle scattered" {
    const arr = [_]i32{ 3, 1, 3, 2, 3, 4 };
    try std.testing.expectEqual(true, linearSearch(arr[0..], 3));
}

test "large-ish not found" {
    var arr: i32 = undefined;
    for (arr[0..], 0..) |*v, i| v.* = @as(i32, @intCast(i * 2)); // evens: 0..62
    try std.testing.expectEqual(false, linearSearch(arr[0..], 63)); // odd, not present
}

test "works with const slice" {
    const base = [_]i32{ 8, 6, 7, 5, 3, 0, 9 };
    const s: []const i32 = base[0..];
    try std.testing.expectEqual(true, linearSearch(s, 0));
    try std.testing.expectEqual(false, linearSearch(s, -10));
}
