import * as THREE from "three"
import { Input } from "./input";

const SPEED = 0.3
const LOOK = 0.01
const TRANSCEND = 0.5
const SMOOTH = [.66, .33, .175, .175]

const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
const geometry = new THREE.PlaneGeometry(2, 4);
const renderer = new THREE.WebGLRenderer();
const scene = new THREE.Scene();

const uniforms = {
    uTime: new THREE.Uniform(0.0),
    uResolution: new THREE.Uniform(new THREE.Vector2(0, 0)),

    uMatrixC: new THREE.Uniform(new THREE.Matrix4()),
    // uPosition: new THREE.Uniform(new THREE.Vector3(0, -0, 20)),
    uPosition: new THREE.Uniform(new THREE.Vector3(0, 0, 20)),
};

const material = new THREE.ShaderMaterial({
    fragmentShader: await (await fetch("./shaders/fragment.glsl")).text(),
    vertexShader: await (await fetch("./shaders/vertex.glsl")).text(),
    uniforms: uniforms,
});

const mesh = new THREE.Mesh(geometry, material);

scene.add(camera);
scene.add(mesh);

renderer.setSize(window.innerWidth, window.innerHeight);
renderer.setAnimationLoop(animate);

document.body.appendChild(renderer.domElement);

const input = new Input()


let time = 0
let yaw = 0
let pitch = 0

const add_shader_vec3 = (v: THREE.Vector3, g: THREE.Vector3) => {
    v.x += g.x
    v.y += g.y
    v.z += g.z
}


let speed = SPEED
function animate() {
    time++
    input.update_input()
    renderer.render(scene, camera)


    const m = uniforms.uMatrixC.value.elements

    const forward = new THREE.Vector3(m[2], m[6], m[10])
    const up = new THREE.Vector3(m[1], m[5], m[9])
    const left = new THREE.Vector3(m[0], m[4], m[8])

    if (input.key("w") && !input.key("s")) {
        forward.multiplyScalar(-speed)
        add_shader_vec3(uniforms.uPosition.value, forward)
    }

    if (input.key("s") && !input.key("w")) {
        forward.multiplyScalar(speed)
        add_shader_vec3(uniforms.uPosition.value, forward)
    }

    if (input.key("a") && !input.key("d")) {
        left.multiplyScalar(-speed)
        add_shader_vec3(uniforms.uPosition.value, left)
    }

    if (input.key("d") && !input.key("a")) {
        left.multiplyScalar(speed)
        add_shader_vec3(uniforms.uPosition.value, left)
    }

    if (input.key("e")) {
        speed = 1;
    } else {
        speed = SPEED;
    }


    if (input.key("space")) {
        add_shader_vec3(uniforms.uPosition.value, new THREE.Vector3(0.0, TRANSCEND, 0.0))
    }

    if (input.key("shift")) {
        add_shader_vec3(uniforms.uPosition.value, new THREE.Vector3(0.0, -TRANSCEND, 0.0))
    }

    if (input.state("locked") && input.state("is_moving")) {
        const value = input.mouse("movement_x")
        const yaw_smooth = input.smooth("movement_x", value, SMOOTH)
        yaw += yaw_smooth * LOOK
    }

    if (input.state("locked") && input.state("is_moving")) {
        const value = input.mouse("movement_y")
        const pitch_smooth = input.smooth("movement_y", value, SMOOTH)
        pitch += pitch_smooth * LOOK
    }


    const yaw_q = new THREE.Quaternion().setFromAxisAngle(new THREE.Vector3(0.0, 1.0, 0.0), yaw)
    const pitch_q = new THREE.Quaternion().setFromAxisAngle(new THREE.Vector3(1.0, 0.0, 0.0), pitch)

    const rotation = new THREE.Quaternion().multiplyQuaternions(pitch_q, yaw_q)
    const rot_matrix = new THREE.Matrix4().makeRotationFromQuaternion(rotation)

    const translation = new THREE.Matrix4().makeTranslation(uniforms.uPosition.value)
    uniforms.uMatrixC.value.multiplyMatrices(rot_matrix, translation)


    uniforms.uTime.value = time
    uniforms.uResolution.value = new THREE.Vector2(
        window.innerWidth,
        window.innerHeight
    );
}