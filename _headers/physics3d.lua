physics3d = {}

function physics3d.init() end
function physics3d.update(dt) end
function physics3d.clear() end
---@return NativePhysicsRectBody
function physics3d.create_rect(x, y, z, w, h, l, static, group, mask) end
function physics3d.destroy_rect(rect) end
---@return NativePhysicsRaycastInfo[]
function physics3d.raycast(x, y, z, x2, y2, z2, mask) end

---@return NativePhysicsCollisionInfo[]
function physics3d.get_collision_info() end

---@class NativePhysicsCollisionManifoldPointInfo
---@field point1 vector3
---@field point2 vector3
---@field normal vector3
---@field depth number

---@class NativePhysicsCollisionManifoldInfo
---@class points NativePhysicsCollisionManifoldPointInfo[]

---@class NativePhysicsCollisionInfo
---@field body1 NativePhysicsRectBody
---@field body2 NativePhysicsRectBody
---@field manifolds NativePhysicsCollisionManifoldInfo[]

---@class NativePhysicsRaycastInfo
---@field position vector3
---@field body NativePhysicsRectBody

---@class NativePhysicsRectBody
local NativePhysicsRectBody = {}
function NativePhysicsRectBody:is_static() end
function NativePhysicsRectBody:get_position() end
function NativePhysicsRectBody:get_size() end
function NativePhysicsRectBody:set_position(x, y, z) end
function NativePhysicsRectBody:set_user_data(data) end
---@return EntityGame|nil
function NativePhysicsRectBody:get_user_data() end