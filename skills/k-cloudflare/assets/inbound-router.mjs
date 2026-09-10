/** Email Worker: route @<yourdomain.com> aliases to verified destinations. */
const KAPIVHA = "<primary@gmail.com>";
const HOTMAIL = "<personal@hotmail.com>";
const LABS = "<labs@gmail.com>";

export default {
  async email(message) {
    const to = (message.to || "").toLowerCase();

    if (to.includes("mail@<yourdomain.com>")) {
      await message.forward(HOTMAIL);
      await message.forward(KAPIVHA);
      return;
    }

    if (to.includes("contact@<yourdomain.com>")) {
      await message.forward(LABS);
      await message.forward(KAPIVHA);
      return;
    }

    if (to.includes("personal@<yourdomain.com>")) {
      await message.forward(HOTMAIL);
      return;
    }

    // Default (unknown address) — forward to the primary inbox.
    await message.forward(KAPIVHA);
  },
};
