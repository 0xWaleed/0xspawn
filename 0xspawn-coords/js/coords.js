(function (g) {
  function invokeCallback(path, payload) {
    if (payload !== undefined) {
      payload = JSON.stringify(payload);
    }
    return fetch(`https://${path}`, {
      method: "POST",
      headers: {
        "Content-Type": "application/json; charset=UTF-8",
      },
      body: payload
    }).then(r => r.json());
  }

  g.getCoords = function () {
    return invokeCallback("coords");
  };

  class LocationCard extends HTMLElement {
    static template = document.getElementById("0xspawn-card-template");

    constructor(id, label, imageUrl) {
      super();
      const shadow = this.attachShadow({mode: "closed"});
      const newTemplate = document.createElement("template");
      newTemplate.innerHTML = LocationCard.template.innerHTML;
      newTemplate.innerHTML = newTemplate.innerHTML.replace("{{label}}", label)
          .replace("{{image-url}}", imageUrl);
      const card = newTemplate.content.cloneNode(true);
      shadow.append(card);
      this.onclick = async () => {
        await invokeCallback("0xspawn-manager/spawn", id);
        this.dispatchEvent(new CustomEvent("spawned", {
          bubbles: true
        }));
      };
    }
  }

  customElements.define("x-0xspawn-card", LocationCard);

  function handleSpawnUI(locations) {
    const spawnContainer = document.getElementById("cards");

    if (!spawnContainer) {
      return;
    }

    window.dispatchEvent(new CustomEvent("spawn-requested", {
      detail: locations
    }));

    spawnContainer.innerHTML = "";
    let last = null;
    for (const location of locations) {
      const card = new LocationCard(location.id, location.label, location.imageUrl);
      spawnContainer.append(card);
      last = location;
    }
  }

  addEventListener("message", (e) => {
    const payload = e.data;
    if (payload.name !== "0xspawn") {
      return;
    }

    if (payload.type === "spawn-ui") {
      handleSpawnUI(payload.data);
    }
  });
})(window);
