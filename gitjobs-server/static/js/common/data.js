/**
 * Returns a list of available job benefits.
 * Used for multiselect and filter components.
 * @returns {string[]} Array of benefit identifiers
 */
export const getBenefits = () => {
  return [
    "401k",
    "flexible-hours",
    "remote-friendly",
    "health-insurance",
    "paid-time-off",
    "4-day-workweek",
    "company-retreats",
    "home-office-budget",
    "learning-budget",
    "mental-wellness-bugdet",
    "equity-compensation",
    "no-whiteboard-interview",
  ];
};

/**
 * Returns a list of available technical skills.
 * Used for multiselect and filter components.
 * @returns {string[]} Array of skill identifiers
 */
export const getSkills = () => {
  return [
    // Dronecode projects
    "px4",
    "pixhawk",
    "mavlink",
    "mavsdk",
    "qgroundcontrol",
    // Other autopilot stacks people are hired on
    "ardupilot",
    "betaflight",
    // Robotics middleware
    "ros-2",
    // Embedded and firmware
    "embedded-systems",
    "embedded-linux",
    "rtos",
    "nuttx",
    "device-drivers",
    "arm-cortex-m",
    "stm32",
    "uavcan",
    // Languages and tooling
    "c",
    "c++",
    "python",
    "rust",
    "qt-qml",
    "linux",
    "git",
    "ci/cd",
    // Guidance, navigation, control and autonomy
    "control-systems",
    "state-estimation",
    "path-planning",
    "computer-vision",
    "slam",
    "machine-learning",
    "gnss",
    // Hardware
    "pcb-design",
    "motor-control",
    "power-electronics",
    "rf-engineering",
    "mechanical-design",
    "manufacturing",
    // Simulation, test and operations
    "simulation",
    "hardware-in-the-loop",
    "flight-testing",
    "flight-operations",
    // Regulatory and safety
    "regulatory-compliance",
    "functional-safety",
    "security",
    // Backend and platform
    "cloud-infrastructure",
    // Non-engineering
    "project-management",
    "open-source-ecosystems",
    "community-management",
    "developer-relations",
    "technical-writing",
  ];
};

// Display names for skills identifiers
export const skillsDisplayName = {
  ardupilot: "ArduPilot",
  "arm-cortex-m": "ARM Cortex-M",
  betaflight: "Betaflight",
  "ci/cd": "CI/CD",
  "embedded-linux": "Embedded Linux",
  gnss: "GNSS",
  "hardware-in-the-loop": "Hardware-in-the-loop",
  mavlink: "MAVLink",
  mavsdk: "MAVSDK",
  nuttx: "NuttX",
  "pcb-design": "PCB design",
  px4: "PX4",
  qgroundcontrol: "QGroundControl",
  "qt-qml": "Qt/QML",
  "rf-engineering": "RF engineering",
  "ros-2": "ROS 2",
  rtos: "RTOS",
  slam: "SLAM",
  stm32: "STM32",
  uavcan: "UAVCAN",
};
