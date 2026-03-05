let lastUpdate = 0;
const bufferTime = 60000;

/**
 * @fn pingServer
 * @brief Checks and updates the user's session activity status.
 * * @details This function sends a request to the server to signal user activity 
 * (like mouse movements or key presses). It uses a throttling mechanism 
 * via `bufferTime` to avoid overwhelming the server with requests.
 * * If the server returns "logout", the user is alerted and redirected to the logout page.
 * * @return {void}
 */

function pingServer() {
    const now = Date.now();

    if (now - lastUpdate > bufferTime) {

        fetch(`${url}user/userActivity`)
            .then(response => response.text())
            .then(data => {
                console.log(data);
                if (data === "logout") {
                    alert("Votre session a expiré pour inactivité. Vous allez être redirigé.");
                    window.location.href = `${url}user/logout`;
                } else {
                    console.log("Session prolongée");
                }
            })
            .catch(err => console.error("Erreur de connexion", err));

        lastUpdate = now;
    }
}

/**
 * @brief Event listeners to track user interaction for session management.
 */
window.addEventListener('mousemove', pingServer);
window.addEventListener('keydown', pingServer);
