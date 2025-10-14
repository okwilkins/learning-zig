const std = @import("std");
const Allocator = std.mem.Allocator;

fn quickSort(comptime T: type, items: []T) void {
    if (items.len <= 1) return;

    const pivot = items[items.len - 1];
    std.debug.print("Pivot: {d}\n", .{pivot});
    var i: usize = 0;

    for (items[0..items.len], 0..) |item, j| {
        if (item < pivot) {
            std.mem.swap(T, &items[i], &items[j]);
            i += 1;
        }
        std.debug.print(
            "i: {d} | j: {d} | Array: {any}\n",
            .{ i, j, items },
        );
    }

    std.mem.swap(T, &items[i], &items[items.len - 1]);

    quickSort(T, items[0..i]);
    if (i + 1 < items.len) {
        quickSort(T, items[i + 1 ..]);
    }
}

pub fn main() !void {
    var prng = std.Random.DefaultPrng.init(50);
    var items: [10]usize = undefined;

    for (0..10) |i| {
        items[i] = prng.random().intRangeAtMost(usize, 0, 10);
    }

    std.debug.print("Pre-sorted array: {any}\n", .{items});
    quickSort(usize, &items);
    std.debug.print("Sorted array: {any}\n", .{items});
}
