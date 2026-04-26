const express = require("express");
const {
  markAttendance,
  getAttendanceByStudent,
  getAllRecords,
  summarizeAttendance
} = require("./attendanceService");

const app = express();

app.use(express.json());

app.get("/health", (req, res) => {
  res.status(200).json({
    status: "ok",
    service: "attendance-api"
  });
});

app.post("/api/attendance", (req, res) => {
  try {
    const { studentId, status } = req.body;
    const record = markAttendance(studentId, status);

    res.status(201).json({
      message: "Attendance marked successfully",
      data: record
    });
  } catch (error) {
    res.status(400).json({
      error: error.message
    });
  }
});

app.get("/api/attendance", (req, res) => {
  res.status(200).json({
    data: getAllRecords()
  });
});

app.get("/api/attendance/:studentId", (req, res) => {
  res.status(200).json({
    data: getAttendanceByStudent(req.params.studentId)
  });
});

app.get("/api/summary", (req, res) => {
  res.status(200).json({
    data: summarizeAttendance()
  });
});

module.exports = app;