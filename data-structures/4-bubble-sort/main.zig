const std = @import("std");

fn bubbleSort(arr: []isize) []isize {
    if (arr.len <= 1) {
        return arr;
    }

    for (0..arr.len) |i| {
        for (0..arr.len - i - 1) |j| {
            if (arr[j] > arr[j + 1]) {
                const tmp: isize = arr[j];
                arr[j] = arr[j + 1];
                arr[j + 1] = tmp;
            }
        }
    }
    return arr;
}

// LLM written tests

// Helper: assert non-decreasing order
fn expectSortedAsc(arr: []const isize) !void {
    var i: usize = 1;
    while (i < arr.len) : (i += 1) {
        try std.testing.expect(arr[i - 1] <= arr[i]);
    }
}

test "bubbleSort: empty slice" {
    var input = [_]isize{};
    const out = bubbleSort(input[0..]);
    try std.testing.expectEqual(@as(usize, 0), out.len);
}

test "bubbleSort: single element" {
    var input = [_]isize{5};
    const out = bubbleSort(input[0..]);
    try std.testing.expectEqualSlices(isize, &[_]isize{5}, out);
}

test "bubbleSort: already sorted" {
    var input = [_]isize{ 1, 2, 3, 4 };
    const out = bubbleSort(input[0..]);
    try std.testing.expectEqualSlices(isize, &[_]isize{ 1, 2, 3, 4 }, out);
    try expectSortedAsc(out);
}

test "bubbleSort: reverse order" {
    var input = [_]isize{ 4, 3, 2, 1 };
    const out = bubbleSort(input[0..]);
    try std.testing.expectEqualSlices(isize, &[_]isize{ 1, 2, 3, 4 }, out);
    try expectSortedAsc(out);
}
