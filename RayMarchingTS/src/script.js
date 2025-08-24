import { input, update_input } from "./input"
import * as THREE from "three"

const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
const geometry = new THREE.PlaneGeometry(2, 4);
const renderer = new THREE.WebGLRenderer();
const scene = new THREE.Scene();

const uniforms = {
    uTime: new THREE.Uniform(0.0),
    uLightPos: new THREE.Uniform(new THREE.Vector3(10, 10, 0)),
    uSunDirection: new THREE.Uniform(new THREE.Vector3(.5, .7, .2)),
    uResolution: new THREE.Uniform(new THREE.Vector2(0, 0)),

    uMatrixC: new THREE.Uniform(new THREE.Matrix4()),
    uPosition: new THREE.Uniform(new THREE.Vector3(0, 0, 5)),
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


let time = 0

let yaw = 0
let pitch = 0

const speed = 0.05
const rotate = 0.05

const add_shader_vec3 = (v, g) => {
    v.x += g.x
    v.y += g.y
    v.z += g.z
}

let pre_val_test1 = 0
let pre_val_test2 = 0
let pre_val_test3 = 0
let pre_val_test4 = 0

let pre_vay_test1 = 0
let pre_vay_test2 = 0
let pre_vay_test3 = 0
let pre_vay_test4 = 0

function animate() {
    time++
    renderer.render(scene, camera)
    update_input()

    const m = uniforms.uMatrixC.value.elements

    const forward = new THREE.Vector3(m[2], m[6], m[10])
    const up = new THREE.Vector3(m[1], m[5], m[9])
    const left = new THREE.Vector3(m[0], m[4], m[8])

    if (input["w"]) {
        forward.multiplyScalar(-speed)
        add_shader_vec3(uniforms.uPosition.value, forward)
    }

    if (input["s"]) {
        forward.multiplyScalar(speed)
        add_shader_vec3(uniforms.uPosition.value, forward)
    }

    if (input["a"]) {
        left.multiplyScalar(-speed)
        add_shader_vec3(uniforms.uPosition.value, left)
    }

    if (input["d"]) {
        left.multiplyScalar(speed)
        add_shader_vec3(uniforms.uPosition.value, left)
    }

    console.log(input.is_moving)
    if (input.locked && input.is_moving) {
        yaw += pre_val_test1 * .50 + pre_val_test2 * .25 + pre_val_test3 * .125 + pre_val_test4 * .0625
        // yaw += input.movement_x * 0.01
        
        const val = input.movement_x * 0.01
        
        pre_val_test4 = pre_val_test3
        pre_val_test3 = pre_val_test2
        pre_val_test2 = pre_val_test1
        pre_val_test1 = val
    }

    if (input.locked && input.is_moving) {
        // pitch += input.movement_y * 0.01

        pitch += pre_vay_test1 * .50 + pre_vay_test2 * .25 + pre_vay_test3 * .125 + pre_vay_test4 * .0625
        // yaw += input.movement_x * 0.01
        
        const val = input.movement_y * 0.01
        
        pre_vay_test4 = pre_vay_test3
        pre_vay_test3 = pre_vay_test2
        pre_vay_test2 = pre_vay_test1
        pre_vay_test1 = val
    }


    const yaw_q = new THREE.Quaternion().setFromAxisAngle(new THREE.Vector3(0.0, 1.0, 0.0), yaw)
    const pitch_q = new THREE.Quaternion().setFromAxisAngle(new THREE.Vector3(1.0, 0.0, 0.0), pitch)

    const rotation = new THREE.Quaternion().multiplyQuaternions(pitch_q, yaw_q)
    const rot_matrix = new THREE.Matrix4().makeRotationFromQuaternion(rotation)

    const translation = new THREE.Matrix4().makeTranslation(uniforms.uPosition.value)
    uniforms.uMatrixC.value.multiplyMatrices(rot_matrix, translation)


    uniforms.uResolution.value = new THREE.Vector2(
        window.innerWidth,
        window.innerHeight
    );
}