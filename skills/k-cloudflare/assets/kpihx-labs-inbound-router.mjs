/** Email Worker: route @kpihx-labs.com aliases to verified destinations. */
const KAPIVHA = "kapoivha@gmail.com";
const HOTMAIL = "ivann.kamdem@hotmail.com";
const LABS = "kpihx.labs@gmail.com";

export default {
  async email(message) {
    const to = (message.to || "").toLowerCase();

    if (to.includes("kpihx@kpihx-labs.com")) {
      await message.forward(HOTMAIL);
      await message.forward(KAPIVHA);
      return;
    }

    if (to.includes("contact@kpihx-labs.com")) {
      await message.forward(LABS);
      await message.forward(KAPIVHA);
      return;
    }

    if (to.includes("ivann@kpihx-labs.com")) {
      await message.forward(HOTMAIL);
      return;
    }

    // Default (unknown address) — forward to the primary inbox.
    await message.forward(KAPIVHA);
  },
};
