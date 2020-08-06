function getfilename() {
	document.getElementById("musicname").value = document.getElementById("musicfile").value;
	document.getElementById("photoname").value = document.getElementById("photofile").value;
	document.getElementById("videoname").value = document.getElementById("videofile").value;
	document.getElementById("docname").value = document.getElementById("documents").value;
}

function show(name) {
	var op = ["dmusic", "dimage", "dvideo", "ddoc"];

	for(var i = 0; i < op.length; i++){
		var info = document.querySelectorAll("."+op[i]);
		for(var n = 0; n < info.length; n++){
			info[n].style.display = "none";
		}
	}
	var ninfo = document.querySelectorAll("."+name);
	for(var v = 0; v < ninfo.length; v++){
		ninfo[v].style.display = "block"
	}
}
