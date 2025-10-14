const std = @import("std");
const Allocator = std.mem.Allocator;

fn quickSort(comptime T: type, items: []T, low: usize, high: usize) void {
    if (low >= high) return;

    const pivotIdx = partition(T, items, low, high);
    quickSort(T, items, low, pivotIdx - 1);
    quickSort(T, items, pivotIdx + 1, high);
}

fn partition(comptime T: type, items: []T, low: usize, high: usize) usize {
    const pivot = items[high];
    std.debug.print("Pivot selected: {d} | Low: {d} | High: {d}\n", .{ pivot, low, high });

    var idx: usize = 0;
    if (low > 0) idx = low - 1;

    for (low..high) |i| {
        std.debug.print("i: {d} | index: {d} | array: {any}\n", .{ i, idx, items });
        if (items[i] <= pivot) {
            idx += 1;
            std.mem.swap(T, &items[i], &items[idx]);
        }
    }

    idx += 1;
    items[high] = items[idx];
    items[idx] = pivot;
    return idx;
}

pub fn main() !void {
    var prng = std.Random.DefaultPrng.init(50);
    var items: [10]usize = undefined;

    for (0..10) |i| {
        items[i] = prng.random().intRangeAtMost(usize, 0, 10);
    }

    std.debug.print("Pre-sorted array: {any}\n", .{items});
    quickSort(usize, &items, 0, items.len - 1);
    std.debug.print("Sorted array: {any}\n", .{items});
}
