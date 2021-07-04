function send(form) {

    let formdata = new FormData
    for (var i = 0; i < form.length; i++) {

        formdata.append(form[i].keys, form[i].values)
    }

    let param = {
        method : "POST",
        body : formdata
    }
    fetch("/receive", param)
        .then((x) => x.text())
        //.then((x) => console.log(x))
}

function readFiles(id) {
    let files = document.getElementById(id).files;

    for (var i = 0; i < files.length; i++) {
        let reader = new FileReader();
        let name = files[i].name;
        reader.readAsText(files[i], "UTF-8");
        reader.onload = function (evt) {
            send([
                    {
                        keys : "filename",
                        values : name
                    },
                    {
                        keys : "file",
                        values : evt.target.result
                    }
                ]);
        }
        reader.onerror = function (evt) {
            console.log("error reading file");
        }
    }
}