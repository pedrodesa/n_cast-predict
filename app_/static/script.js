async function startPipeline() {
    const statusDiv = document.getElementById("status");
    statusDiv.innerHTML = "Starting pipeline...";

    try {
        const response = await fetch("/start-pipeline/", { method: "POST" });
        const data = await response.json();

        if (data.status) {
            statusDiv.innerHTML = data.status;
        } else {
            statusDiv.innerHTML = "Error starting pipeline.";
        }
    } catch (error) {
        console.error("Error:", error);
        statusDiv.innerHTML = "Failed to start pipeline.";
    }
}

