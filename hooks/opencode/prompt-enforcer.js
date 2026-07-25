/**
 * KπX Prompt Enforcer — OpenCode plugin.
 * Reads the enforcement text from core/prompt_enforcer.txt and injects it.
 */
const fs = require("fs");
const path = require("path");

module.exports = async function() {
  const txtPath = path.join(process.env.HOME, ".agents", "hooks", "core", "prompt_enforcer.txt");
  let enforcementText = "";
  try {
    enforcementText = fs.readFileSync(txtPath, "utf8").trim();
  } catch (e) {
    enforcementText = "ERROR READING PROMPT ENFORCER: " + e.message;
  }

  return {
    "experimental.chat.messages.transform": async (_input, output) => {
      const msgsStr = JSON.stringify(output.messages || []);
      if (!msgsStr.includes('"Colab"') && !msgsStr.includes('"Build"') && !msgsStr.includes('"Auto"')) return;

      output.messages = output.messages || [];
      output.messages.push({
        role: "user",
        content: enforcementText
      });
    },
  };
}
