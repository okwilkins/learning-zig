const std = @import("std");
const Allocator = std.mem.Allocator;
const assert = std.debug.assert;

const RingBufferError = error{
    Full,
    Empty,
};

fn RingBuffer(comptime T: type) type {
    return struct {
        const Self = @This();
        allocator: Allocator,
        items: []T = undefined,

        read_idx: usize,
        write_idx: usize,
        count: usize = 0,

        fn init(size: usize, allocator: Allocator) !Self {
            const items = try allocator.alloc(T, size);
            return Self{
                .items = items,
                .allocator = allocator,
                .write_idx = 0,
                .read_idx = 0,
            };
        }

        fn deinit(self: *Self) void {
            self.allocator.free(self.items);
            self.* = undefined;
        }

        fn ringIdx(self: *const Self, idx: usize) usize {
            return idx % self.items.len;
        }

        fn twiceRingIdx(self: *const Self, idx: usize) usize {
            return idx % (self.items.len * 2);
        }

        fn full(self: *const Self) bool {
            return self.count == self.items.len;
        }

        fn empty(self: *const Self) bool {
            return self.read_idx == self.write_idx;
        }

        fn put(self: *Self, value: T) RingBufferError!void {
            if (self.full()) return error.Full;
            self.items[self.write_idx] = value;
            self.write_idx = self.ringIdx(self.write_idx +% 1);
            self.count += 1;
        }

        fn get(self: *Self) ?T {
            if (self.empty()) return null;
            const read_value = self.items[self.ringIdx(self.read_idx)];
            self.read_idx = self.ringIdx(self.read_idx +% 1);
            self.count -= 1;
            return read_value;
        }
    };
}

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}).init;
    const allocator = gpa.allocator();

    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("Memory leaked!");
    }

    var buff = try RingBuffer(usize).init(10, allocator);
    defer buff.deinit();

    var i: usize = 0;
    while (i < 20) : (i += 1) {
        buff.put(i) catch |err| {
            switch (err) {
                error.Full => std.debug.print("Array is full for index: {d}\n", .{i}),
                else => {},
            }
        };
    }

    std.debug.print("Length: {d}\n", .{buff.items.len});

    while (i < 20) : (i += 1) {
        const value = buff.get();
        std.debug.print("{d}\n", .{value.?});
    }

    for (buff.items, 0..10) |value, index| {
        std.debug.print("{d}: {d}\n", .{ index, value });
    }

    std.debug.print("Length: {d}\n", .{buff.items.len});
}
