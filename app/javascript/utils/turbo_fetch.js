import { Turbo } from "@hotwired/turbo-rails"

const turboFetch = async (url) => {
  try {
    const response = await fetch(url, {
      headers: { "Accept": "text/vnd.turbo-stream.html" }
    });

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`);
    }

    const html = await response.text();
    Turbo.renderStreamMessage(html);
  }
  catch (error) {
    console.error('Error fetching Turbo stream:', error);
  }
}

export { turboFetch }
