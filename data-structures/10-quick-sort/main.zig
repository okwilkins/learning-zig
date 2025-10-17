const std = @import("std");
const Allocator = std.mem.Allocator;

const QuickSortStrat = enum {
    firstElement,
    lastElement,
    middleElement,
    randomElement,
    medianOfThree,
};

fn CreatePivoter(comptime T: type, strat: QuickSortStrat) Pivoter {
    switch (strat) {
        .firstElement => {
            return FirstElementPivoter(T);
        },
        .lastElement => {
            return LastElementPivoter(T);
        },
        _ => {
            unreachable;
        },
    }
}

fn Pivoter(comptime T: type) type {
    return struct {
        const Self = @This();

        ptr: *anyopaque,
        vtable: *const VTable,

        const VTable = struct {
            pivot: *const fn (*anyopaque, []T) usize,
        };

        fn pivot(self: Self, items: []T) usize {
            return self.vtable.pivot(self.ptr, items);
        }
    };
}

fn FirstElementPivoter(comptime T: type) type {
    return struct {
        const Self = @This();

        fn getPivotIndex(items: []T) usize {
            _ = items;
            return 0;
        }

        fn getPivotIndexOpaque(ptr: *anyopaque, items: []T) usize {
            const pivoter: *Self = @ptrCast(@alignCast(ptr));
            return pivoter.getPivotIndex(items);
        }
    };
}

fn LastElementPivoter(comptime T: type) type {
    return struct {
        const Self = @This();

        fn getPivotIndex(items: []T) usize {
            return items.len - 1;
        }

        fn getPivotIndexOpaque(ptr: *anyopaque, items: []T) usize {
            const pivoter: *Self = @ptrCast(@alignCast(ptr));
            return pivoter.getPivotIndex(items);
        }
    };
}

fn quickSorter(comptime T: type) type {
    return struct {
        const Self = @This();
        strat: QuickSortStrat,

        fn init(strat: QuickSortStrat) Self {
            return Self{ .strat = strat };
        }

        fn sort(self: *Self, items: []T) void {
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

            self.sort(items[0..i]);
            if (i + 1 < items.len) {
                self.sort(items[i + 1 ..]);
            }
        }
    };
}

pub fn main() !void {
    var prng = std.Random.DefaultPrng.init(50);
    var items: [10]usize = undefined;

    for (0..10) |i| {
        items[i] = prng.random().intRangeAtMost(usize, 0, 10);
    }

    std.debug.print("Pre-sorted array: {any}\n", .{items});
    var sorter = quickSorter(usize).init(QuickSortStrat.lastElement);
    sorter.sort(&items);
    std.debug.print("Sorted array: {any}\n", .{items});
}
