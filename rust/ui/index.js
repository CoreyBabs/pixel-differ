// access the pre-bundled global API functions
const { invoke } = window.__TAURI__.tauri;

async function openDialog() {
	window.__TAURI__.dialog.open({
		multiple: false,
		filters: [{name: "Image", extensions: ["png", "jpeg", "jpg"]}]
	}).then((selected) => setImage(selected));
}

let imgPath = "";
document.getElementById("file-select").addEventListener("click", () => openDialog());
document.getElementById("run").addEventListener("click", () => runCorruption());

async function runCorruption() {
	if (imgPath === "") return;
	console.log("running corruption");
	let elem = document.getElementById("threshold");
	const threshold = parseInt(elem.value);
	invoke('corrupt_image', { inputPath: imgPath, threshold: threshold })
		.then((response) => console.log(`Gif written to ${response}`));
}


// document.getElementById("file").addEventListener("change", (e) => {
async function setImage(selected) {
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

	imgPath = selected;
}
