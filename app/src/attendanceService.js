const allowedStatuses = ["present", "absent", "late"];
let records = [];

function validateStudentId(studentId) {
  return typeof studentId === "string" && /^STU-\d{3}$/.test(studentId);
}

function validateStatus(status) {
  return allowedStatuses.includes(status);
}

function markAttendance(studentId, status) {
  if (!validateStudentId(studentId)) {
    throw new Error("Invalid studentId");
  }

  if (!validateStatus(status)) {
    throw new Error("Invalid attendance status");
  }

  const record = {
    id: records.length + 1,
    studentId,
    status,
    markedAt: new Date().toISOString()
  };

  records.push(record);
  return record;
}

function getAttendanceByStudent(studentId) {
  return records.filter((record) => record.studentId === studentId);
}

function getAllRecords() {
  return records;
}

function clearRecords() {
  records = [];
}

function summarizeAttendance() {
  return records.reduce(
    (summary, record) => {
      summary.total += 1;
      summary[record.status] += 1;
      return summary;
    },
    {
      total: 0,
      present: 0,
      absent: 0,
      late: 0
    }
  );
}

module.exports = {
  validateStudentId,
  validateStatus,
  markAttendance,
  getAttendanceByStudent,
  getAllRecords,
  clearRecords,
  summarizeAttendance
};
