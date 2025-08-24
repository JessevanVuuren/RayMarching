import * as THREE from "three";
import { keyboard_state } from "./keyboard";

const camera = new THREE.OrthographicCamera(-1, 1, 1, -1, 0, 1);
const geometry = new THREE.PlaneGeometry(2, 4);
const renderer = new THREE.WebGLRenderer();
const scene = new THREE.Scene();

const uniforms = {
    uTime: new THREE.Uniform(0.0),
    uLightPos: new THREE.Uniform(new THREE.Vector3(10, 10, 0)),
    uSunDirection: new THREE.Uniform(new THREE.Vector3(.5, .7, .2)),
    uResolution: new THREE.Uniform(new THREE.Vector2(0, 0)),

    uPosition: new THREE.Uniform(new THREE.Vector3(0, 0, 5)),
    uCamera_fwd: new THREE.Uniform(new THREE.Vector3(0.0, 0.0, 1.0)),
    uCamera_up: new THREE.Uniform(new THREE.Vector3(0.0, 1.0, 0.0)),
    uCamera_right: new THREE.Uniform(new THREE.Vector3(-1.0, 0.0, 0.0))
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


let time = 0;

let yaw = 0;
let roll = 0;
let pitch = 0.1;

const speed = 0.1;
const rotate = 0.01;



function animate() {
    time++;
    renderer.render(scene, camera)

    if (keyboard_state["w"]) {
        uniforms.uPosition.value.x -= uniforms.uCamera_fwd.value.x * 0.05
        uniforms.uPosition.value.y -= uniforms.uCamera_fwd.value.y * 0.05
        uniforms.uPosition.value.z -= uniforms.uCamera_fwd.value.z * 0.05
    }

    if (keyboard_state["s"]) {
        uniforms.uPosition.value.x += uniforms.uCamera_fwd.value.x * 0.05
        uniforms.uPosition.value.y += uniforms.uCamera_fwd.value.y * 0.05
        uniforms.uPosition.value.z += uniforms.uCamera_fwd.value.z * 0.05
    }

    if (keyboard_state["q"]) {
        pitch = -0.01

        uniforms.uCamera_fwd.value.x = Math.cos(pitch) * uniforms.uCamera_fwd.value.x + Math.sin(pitch) * uniforms.uCamera_up.value.x
        uniforms.uCamera_fwd.value.y = Math.cos(pitch) * uniforms.uCamera_fwd.value.y + Math.sin(pitch) * uniforms.uCamera_up.value.y
        uniforms.uCamera_fwd.value.z = Math.cos(pitch) * uniforms.uCamera_fwd.value.z + Math.sin(pitch) * uniforms.uCamera_up.value.z

        uniforms.uCamera_up.value.x = -Math.sin(pitch) * uniforms.uCamera_fwd.value.x + Math.cos(pitch) * uniforms.uCamera_up.value.x
        uniforms.uCamera_up.value.y = -Math.sin(pitch) * uniforms.uCamera_fwd.value.y + Math.cos(pitch) * uniforms.uCamera_up.value.y
        uniforms.uCamera_up.value.z = -Math.sin(pitch) * uniforms.uCamera_fwd.value.z + Math.cos(pitch) * uniforms.uCamera_up.value.z
    }

    if (keyboard_state["e"]) {
        pitch = 0.01
        uniforms.uCamera_fwd.value.x = Math.cos(pitch) * uniforms.uCamera_fwd.value.x + Math.sin(pitch) * uniforms.uCamera_up.value.x
        uniforms.uCamera_fwd.value.y = Math.cos(pitch) * uniforms.uCamera_fwd.value.y + Math.sin(pitch) * uniforms.uCamera_up.value.y
        uniforms.uCamera_fwd.value.z = Math.cos(pitch) * uniforms.uCamera_fwd.value.z + Math.sin(pitch) * uniforms.uCamera_up.value.z

        uniforms.uCamera_up.value.x = -Math.sin(pitch) * uniforms.uCamera_fwd.value.x + Math.cos(pitch) * uniforms.uCamera_up.value.x
        uniforms.uCamera_up.value.y = -Math.sin(pitch) * uniforms.uCamera_fwd.value.y + Math.cos(pitch) * uniforms.uCamera_up.value.y
        uniforms.uCamera_up.value.z = -Math.sin(pitch) * uniforms.uCamera_fwd.value.z + Math.cos(pitch) * uniforms.uCamera_up.value.z
    }

    uniforms.uResolution.value = new THREE.Vector2(
        window.innerWidth,
        window.innerHeight
    );
}