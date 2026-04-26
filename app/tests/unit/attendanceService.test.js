const {
  validateStudentId,
  validateStatus,
  markAttendance,
  getAttendanceByStudent,
  getAllRecords,
  clearRecords,
  summarizeAttendance
} = require("../../src/attendanceService");

beforeEach(() => {
  clearRecords();
});

describe("attendanceService unit tests", () => {
  test("validates correct student ID format", () => {
    expect(validateStudentId("STU-001")).toBe(true);
  });

  test("rejects incorrect student ID format", () => {
    expect(validateStudentId("001")).toBe(false);
  });

  test("validates allowed attendance statuses", () => {
    expect(validateStatus("present")).toBe(true);
    expect(validateStatus("absent")).toBe(true);
    expect(validateStatus("late")).toBe(true);
  });

  test("rejects unsupported attendance status", () => {
    expect(validateStatus("holiday")).toBe(false);
  });

  test("marks attendance successfully", () => {
    const record = markAttendance("STU-002", "present");

    expect(record.id).toBe(1);
    expect(record.studentId).toBe("STU-002");
    expect(record.status).toBe("present");
    expect(getAllRecords()).toHaveLength(1);
  });

  test("throws error for invalid student ID", () => {
    expect(() => markAttendance("BAD-ID", "present")).toThrow("Invalid studentId");
  });

  test("summarizes attendance records correctly", () => {
    markAttendance("STU-001", "present");
    markAttendance("STU-002", "absent");
    markAttendance("STU-003", "late");

    expect(summarizeAttendance()).toEqual({
      total: 3,
      present: 1,
      absent: 1,
      late: 1
    });
  });

  test("gets attendance records by student ID", () => {
    markAttendance("STU-004", "present");
    markAttendance("STU-004", "late");
    markAttendance("STU-005", "absent");

    expect(getAttendanceByStudent("STU-004")).toHaveLength(2);
  });
});