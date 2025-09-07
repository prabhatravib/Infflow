const { PlacesUtils } = ChromeUtils.importESModule(
  "resource://gre/modules/PlacesUtils.sys.mjs"
);
const { Services } = ChromeUtils.importESModule(
  "resource://gre/modules/Services.sys.mjs"
);

class InfflowHome {
  constructor() {
    this.init();
  }

  async init() {
    console.log("Infflow Home Initialized");
    // Example: Fetch and log top sites
    const topSites = await PlacesUtils.history.getTopSites(10);
    console.log("Top Sites:", topSites);

    const searchInput = document.getElementById("search-input") as HTMLInputElement;
    searchInput.addEventListener("keypress", (event) => {
      if (event.key === "Enter") {
        const query = searchInput.value;
        const searchService = Services.search.getDefault();
        const submission = searchService.getSubmission(query, null);
        // Open the search in a new tab
        window.open(submission.uri.spec, "_blank");
      }
    });
  }
}

new InfflowHome();
