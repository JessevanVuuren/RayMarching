interface KeyboardState {
  "a": boolean
  "w": boolean
  "d": boolean
  "s": boolean
  "q": boolean
  "e": boolean
  "r": boolean
  "f": boolean
  "shift": boolean
  "space": boolean
  "ctrl": boolean
}

interface GlobalState {
  "last_stored_time": number
}

interface MouseState {
  "left_button": boolean
  "right_button": boolean
  "middle_button": boolean

  "upward": boolean
  "downward": boolean
  "rightward": boolean
  "leftward": boolean

  "is_moving": boolean
  "locked": boolean
}

interface MousePos {
  "pos_x": number
  "pos_y": number

  "pre_pos_x": number
  "pre_pos_y": number

  "delta_x": number
  "delta_y": number
  "movement_y": number
  "movement_x": number
}

type SmoothMotion = { [value: string]: number[] }

export class Input {

  private smoothValues = {} as SmoothMotion
  private keyboard = {} as KeyboardState
  private mouseState = {} as MouseState
  private global = {} as GlobalState
  private mousePos = {} as MousePos

  private body: HTMLBodyElement

  constructor() {
    this.body = document.getElementsByTagName("body")[0]
    document.addEventListener("keydown", (e) => {
      this.update_keyboard(true, e)
    })
    document.addEventListener("keyup", (e) => {
      this.update_keyboard(false, e)
    })

    document.addEventListener("pointerlockchange", (e) => {
      this.mouse_lock_change(e)
    })
    document.addEventListener("mousemove", (e) => {
      this.mouse_movement(e)
    })
    document.addEventListener("mouseout", (e) => {
      this.mouse_out(e)
    })

    document.body.addEventListener('click', () => {
      this.body.requestPointerLock()
    }, false)

  }

  key(k: keyof KeyboardState): boolean {
    return this.keyboard[k]
  }

  state(k: keyof MouseState): boolean {
    return this.mouseState[k]
  }

  mouse(k: keyof MousePos): number {
    return this.mousePos[k]
  }

  smooth(key: string, value: number, weights: number[] = [.5, .25, .125, 0.0625, 0.03125]) {
    if (!(key in this.smoothValues)) {
      this.smoothValues[key] = []
    }

    this.smoothValues[key].unshift(value)
    if (this.smoothValues[key].length > weights.length) {
      this.smoothValues[key].pop()
    }

    let result = 0
    this.smoothValues[key].forEach((value, index) => {
      result += value * weights[index]
    });

    return result
  }

  private update_keyboard(state: boolean, e: KeyboardEvent) {
    let event_key = e.key.toLowerCase()
    if (event_key == " ") event_key = "space"
    if (event_key == "control") event_key = "ctrl"

    if (!Object.keys(this.keyboard).includes(event_key) && state) {
      this.keyboard[event_key as keyof KeyboardState] = state
    }

    for (const key of Object.keys(this.keyboard)) {
      if (event_key == key) {
        this.keyboard[key as keyof KeyboardState] = state;
      }
    }
  }

  private lock_mouse() {
    this.mouseState.locked = true
    this.mousePos.delta_x = this.mousePos.pos_x
    this.mousePos.delta_y = this.mousePos.pos_y
  }

  private unlock_mouse() {
    this.mouseState.locked = false
    this.mousePos.delta_x = 0
    this.mousePos.delta_y = 0
  }

  private mouse_out(_: MouseEvent) {
    this.mouseState.is_moving = false
  }

  update_input() {
    if (performance.now() > this.global.last_stored_time + 50) {
      this.mouseState.is_moving = false
    }
  }

  private mouse_movement(e: MouseEvent) {
    this.global.last_stored_time = performance.now()
    this.mouseState.is_moving = true

    this.mousePos.movement_x = e.movementX
    this.mousePos.movement_y = e.movementY


    this.mouseState.left_button = e.buttons == 1
    this.mouseState.right_button = e.buttons == 2
    this.mouseState.middle_button = e.buttons == 4

    this.mousePos.pos_x = e.offsetX
    this.mousePos.pos_y = e.offsetY

    if (this.mousePos.pos_x > this.mousePos.pre_pos_x) {
      this.mouseState.leftward = false
      this.mouseState.rightward = true
    }

    if (this.mousePos.pos_x < this.mousePos.pre_pos_x) {
      this.mouseState.leftward = true
      this.mouseState.rightward = false
    }

    if (this.mousePos.pos_y > this.mousePos.pre_pos_y) {
      this.mouseState.upward = false
      this.mouseState.downward = true
    }

    if (this.mousePos.pos_y < this.mousePos.pre_pos_y) {
      this.mouseState.upward = true
      this.mouseState.downward = false
    }

    this.mousePos.pre_pos_x = this.mousePos.pos_x
    this.mousePos.pre_pos_y = this.mousePos.pos_y
  }

  private mouse_lock_change(_: Event) {
    if (document.pointerLockElement === this.body) {
      this.lock_mouse()
    } else {
      this.unlock_mouse()
    }
  }


}

