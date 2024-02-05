// access the pre-bundled global API functions
const { invoke } = window.__TAURI__.tauri;

// now we can call our Command!
// You will see "Welcome from Tauri" replaced
// by "Hello, World!"!
// invoke('greet', { name: 'Corey' })
// 	// `invoke` returns a Promise
// 	.then((response) => {
// 		window.header.innerHTML = response
// 	})


async function openDialog() {
	window.__TAURI__.dialog.open({
		multiple: false,
		filters: [{name: "Image", extensions: ["png", "jpeg", "jpg"]}]
	}).then((selected) => setImage(selected));

	// if (selected === null) {
	// 	return;
	// }
	//
	// console.log(selected);
}

document.getElementById("file-select").addEventListener("click", () => openDialog());

// document.getElementById("file").addEventListener("change", (e) => {
async function setImage(selected) {
	console.log(selected);
	window.__TAURI__.fs.exists(selected).then((e) => console.log(e));
	if (selected == null) {
		return;
	}
	
	let path = await window.__TAURI__.tauri.convertFileSrc(selected);	
	let div = document.getElementById("image_container");
	div.replaceChildren([]);
	let img = document.createElement("img");
	img.src = path;
	div.appendChild(img);

	invoke('corrupt_image', { inputPath: selected, threshold: 10 })
		.then((response) => console.log(response));
}
