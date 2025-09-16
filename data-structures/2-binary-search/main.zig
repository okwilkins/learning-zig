const std = @import("std");
const expect = std.testing.expect;
const math = std.math;

fn binarySearch(haystack: []const isize, needle: isize) bool {
    if (haystack.len == 0) return false;
    if (haystack.len == 1 and haystack[0] != needle) return false;

    var low: usize = 0;
    var high: usize = haystack.len;

    while (low < high) {
        const mid = low + (high - low) / 2;
        const value = haystack[mid];

        if (value == needle) {
            return true;
        } else if (value < needle) {
            low = mid + 1;
        } else {
            high = mid;
        }
    }

    return false;
}

// LLM written tests
test "empty slice returns false" {
    const data = [_]isize{};
    try expect(!binarySearch(data[0..], 42));
}

test "single element present" {
    const data = [_]isize{5};
    try expect(binarySearch(data[0..], 5));
}

test "single element absent" {
    const data = [_]isize{5};
    try expect(!binarySearch(data[0..], 4));
}

test "present at first position" {
    const data = [_]isize{ 1, 3, 5, 7, 9 };
    try expect(binarySearch(data[0..], 1));
}

test "present in middle (odd length)" {
    const data = [_]isize{ 1, 3, 5, 7, 9 };
    try expect(binarySearch(data[0..], 5));
}

test "present at last position" {
    const data = [_]isize{ 1, 3, 5, 7, 9 };
    try expect(binarySearch(data[0..], 9));
}

test "absent: lower than all elements" {
    const data = [_]isize{ 10, 20, 30, 40 };
    try expect(!binarySearch(data[0..], -5));
}

test "absent: between existing elements" {
    const data = [_]isize{ 2, 4, 6, 8, 10 };
    try expect(!binarySearch(data[0..], 5));
}

test "absent: greater than all elements" {
    const data = [_]isize{ 2, 4, 6, 8, 10 };
    try expect(!binarySearch(data[0..], 100));
}

test "negative numbers and zero: present" {
    const data = [_]isize{ -10, -5, 0, 10, 20 };
    try expect(binarySearch(data[0..], -5));
    try expect(binarySearch(data[0..], 0));
    try expect(binarySearch(data[0..], 20));
}

test "negative numbers and zero: absent" {
    const data = [_]isize{ -10, -5, 0, 10, 20 };
    try expect(!binarySearch(data[0..], -7));
    try expect(!binarySearch(data[0..], 15));
}

test "duplicates: value present among duplicates" {
    const data = [_]isize{ 1, 2, 2, 2, 3, 4 };
    try expect(binarySearch(data[0..], 2));
}

test "duplicates: value absent near duplicates" {
    const data = [_]isize{ 1, 2, 2, 2, 3, 4 };
    try expect(!binarySearch(data[0..], 5));
}

test "all elements equal: present" {
    const data = [_]isize{ 7, 7, 7, 7, 7 };
    try expect(binarySearch(data[0..], 7));
}

test "all elements equal: absent" {
    const data = [_]isize{ 7, 7, 7, 7, 7 };
    try expect(!binarySearch(data[0..], 6));
}

test "extremes: min and max isize present" {
    const data = [_]isize{
        @as(isize, math.minInt(i32)),
        -1,
        0,
        1,
        @as(isize, math.maxInt(i32)),
    };
    try expect(binarySearch(data[0..], @as(isize, math.minInt(i32))));
    try expect(binarySearch(data[0..], @as(isize, math.maxInt(i32))));
}

test "extremes: below min and above max absent (clamped search space)" {
    // While values outside isize cannot be represented, verify neighbors are handled.
    const data = [_]isize{
        @as(isize, math.minInt(i32)),
        -1,
        0,
        1,
        @as(isize, math.maxInt(i32)),
    };
    try expect(!binarySearch(data[0..], -2)); // not in set
    try expect(!binarySearch(data[0..], 2)); // not in set
}

test "even-length array: present in either middle half" {
    const data = [_]isize{ 2, 4, 6, 8 };
    try expect(binarySearch(data[0..], 4));
    try expect(binarySearch(data[0..], 6));
}

test "even-length array: absent values" {
    const data = [_]isize{ 2, 4, 6, 8 };
    try expect(!binarySearch(data[0..], 1));
    try expect(!binarySearch(data[0..], 3));
    try expect(!binarySearch(data[0..], 5));
    try expect(!binarySearch(data[0..], 7));
    try expect(!binarySearch(data[0..], 9));
}
