const std = @import("std");
const Allocator = std.mem.Allocator;

fn Node(comptime T: type) type {
    return struct {
        value: T,
        next: ?*Node(T) = null,
    };
}

fn Stack(comptime T: type) type {
    return struct {
        const Self = @This();

        head: ?*Node(T) = null,
        len: usize = 0,
        allocator: Allocator,

        fn init(allocator: Allocator) Self {
            return Self{ .allocator = allocator };
        }

        fn deinit(self: *Self) void {
            if (self.head == null) return;
            var current = self.head;

            while (current) |node| {
                const next = node.next;
                self.allocator.destroy(node);
                current = next;
            }
            self.len = 0;
        }

        fn push(self: *Self, value: T) !void {
            const new_head = try self.allocator.create(Node(T));
            new_head.* = .{ .value = value, .next = self.head };
            self.head = new_head;
            self.len += 1;
        }

        fn pop(self: *Self) ?T {
            if (self.head == null) return null;

            const head = self.head.?;
            const value = head.value;

            self.head = head.next;
            self.allocator.destroy(head);
            self.len -= 1;

            return value;
        }

        fn peek(self: *const Self) ?*const T {
            if (self.head) |head| {
                return head.value;
            } else {
                return null;
            }
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

    var stack = Stack(usize).init(allocator);
    defer stack.deinit();

    var i: usize = 0;
    while (i < 100) : (i += 1) {
        try stack.push(i);
    }

    std.debug.print("Length: {d}\n", .{stack.len});

    while (stack.pop()) |value| {
        std.debug.print("Popped value: {d}\n", .{value});
    }

    std.debug.print("Length: {d}\n", .{stack.len});
}
