const body_document = document.getElementsByTagName("body")[0]
var timer


export const input = {
    // keyboard
    "a": false,
    "w": false,
    "d": false,
    "s": false,
    "q": false,
    "e": false,
    "r": false,
    "f": false,

    // mouse
    "left_button": false,
    "right_button": false,
    "middle_button": false,
    "upward": false,
    "downward": false,
    "rightward": false,
    "leftward": false,
    "pos_x": 0,
    "pos_y": 0,
    "pre_pos_x": 0,
    "pre_pos_y": 0,
    "is_moving": false,
    "delta_x": 0,
    "delta_y": 0,
    "locked": false,
    "movement_y": 0,
    "movement_x": 0,

    "last_stored_time": 0
}

const lock_mouse = async () => {
    input.locked = true
    input.delta_x = input.pos_x
    input.delta_y = input.pos_y
}

const unlock_mouse = () => {
    input.locked = false
    input.delta_x = 0
    input.delta_y = 0
}

const mouse_out = () => {
    input.is_moving = false
}

export const update_input = () => {
    if (performance.now() > input.last_stored_time + 50) {
        input.is_moving = false
    }
}

const mouse_movement = (e) => {
    input.last_stored_time = performance.now()
    input.is_moving = true

    input.movement_x = e.movementX
    input.movement_y = e.movementY


    input.left_button = e.buttons == 1
    input.right_button = e.buttons == 2
    input.middle_button = e.buttons == 4

    input.pos_x = e.offsetX
    input.pos_y = e.offsetY

    if (input.pos_x > input.pre_pos_x) {
        input.leftward = false
        input.rightward = true
    }

    if (input.pos_x < input.pre_pos_x) {
        input.leftward = true
        input.rightward = false
    }

    if (input.pos_y > input.pre_pos_y) {
        input.upward = false
        input.downward = true
    }

    if (input.pos_y < input.pre_pos_y) {
        input.upward = true
        input.downward = false
    }

    input.pre_pos_x = input.pos_x
    input.pre_pos_y = input.pos_y
}

const update_keyboard = (state, e) => {
    for (const [key, value] of Object.entries(input)) {
        if (e.key == key) input[key] = state;
    }
}

const keyboard_down = (e) => {
    update_keyboard(true, e)
}
const keyboard_up = (e) => {
    update_keyboard(false, e)
}


const mouse_lock_change = (e) => {
    if (document.pointerLockElement === body_document) {
        lock_mouse()
    } else {
        unlock_mouse()
    }
}


document.addEventListener("pointerlockchange", mouse_lock_change)
document.addEventListener("mousemove", mouse_movement)
document.addEventListener("mouseout", mouse_out)
document.addEventListener("keydown", keyboard_down, false)
document.addEventListener("keyup", keyboard_up, false)

document.body.addEventListener('click', () => {
    body_document.requestPointerLock()
}, false)