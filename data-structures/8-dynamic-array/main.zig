const std = @import("std");
const Allocator = std.mem.Allocator;

fn DynamicArray(comptime T: type) type {
    return struct {
        const Self = @This();
        items: []T,
        len: usize = 0,
        capcacity: usize,
        allocator: Allocator,

        fn init(allocator: Allocator, size: usize) !Self {
            var items = try allocator.alloc(T, size);
            items.len = 0;
            return Self{ .items = items, .capcacity = size, .allocator = allocator };
        }

        fn deinit(self: *Self) void {
            const full_slice = self.items.ptr[0..self.capcacity];
            self.allocator.free(full_slice);
        }

        fn append(self: *Self, value: T) !void {
            var new_capacity = self.capcacity * 2;
            if (new_capacity == 0) new_capacity = 8;

            if (self.len >= self.capcacity) {
                self.items = try self.allocator.realloc(self.items, new_capacity);
                std.debug.print("Allocation occured from {d} to {d}\n", .{ self.capcacity, new_capacity });
                self.capcacity = new_capacity;
            }

            self.len += 1;
            self.items.len = self.len;

            self.items[self.len - 1] = value;
            self.items.len = self.len;
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

    var arr = try DynamicArray(usize).init(allocator, 8);
    defer arr.deinit();

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        try arr.append(i);
    }

    std.debug.print("Length: {d}\n", .{arr.len});

    for (arr.items, 0..) |value, index| {
        std.debug.print("{d}: {d}\n", .{ index, value });
    }

    std.debug.print("Length: {d}\n", .{arr.len});
}
