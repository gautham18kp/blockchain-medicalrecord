async function uploadFile() {
    const fileInput = document.getElementById("fileInput").files[0];
    if (!fileInput) return alert("Select a file!");

    const formData = new FormData();
    formData.append("file", fileInput);

    // Replace with your Storj API URL and API Key
    const storjUploadUrl = "https://gateway.storjshare.io";
    const apiKey = "your-storj-api-key";

    try {
        const response = await fetch(storjUploadUrl, {
            method: "POST",
            headers: {
                "Authorization": `Bearer ${apiKey}`
            },
            body: formData
        });

        const result = await response.json();
        const fileHash = web3.utils.sha3(result.fileUrl);

        await contract.methods.uploadFile(fileHash, result.fileUrl).send({ from: userAccount });
        alert("File uploaded successfully!");

    } catch (error) {
        console.error("Storj Upload Failed:", error);
        alert("Failed to upload file!");
    }
}

async function viewFiles() {
    const patientAddress = document.getElementById("patientAddress").value;
    if (!patientAddress) return alert("Enter a valid patient address.");

    try {
        const files = await contract.methods.getFiles(patientAddress).call({ from: userAccount });
        const fileList = document.getElementById("fileList");
        fileList.innerHTML = "";

        files.forEach(file => {
            const li = document.createElement("li");
            li.innerHTML = `File Hash: ${file.fileHash} <br> 
                            <a href="${file.fileUrl}" target="_blank">View File</a>`;
            fileList.appendChild(li);
        });

    } catch (error) {
        alert("Access denied or no files available!");
    }
}
