module.exports = {
  projectName: "Bloodbath",

  domains: [
    {
      id: 'api',
      local: 'api.bloodbath.local',
      target: 'localhost:4000',
    },
  ],

  greenlock: {
    configDir: './portless/config/greenlock',
    packageAgent: `bloodbath/1.0.0`,
    maintainerEmail: 'laurent.schaffner.code@gmail.com',
  },
}