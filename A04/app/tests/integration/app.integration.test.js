const request = require("supertest");
const app = require("../../src/app");
const { clearRecords } = require("../../src/attendanceService");

beforeEach(() => {
  clearRecords();
});

describe("attendance API integration tests", () => {
  test("GET /health returns service health", async () => {
    const response = await request(app).get("/health");

    expect(response.status).toBe(200);
    expect(response.body.status).toBe("ok");
    expect(response.body.service).toBe("attendance-api");
  });

  test("POST /api/attendance creates attendance record", async () => {
    const response = await request(app)
      .post("/api/attendance")
      .send({
        studentId: "STU-101",
        status: "present"
      });

    expect(response.status).toBe(201);
    expect(response.body.message).toBe("Attendance marked successfully");
    expect(response.body.data.studentId).toBe("STU-101");
    expect(response.body.data.status).toBe("present");
  });

  test("GET /api/summary returns attendance summary", async () => {
    await request(app).post("/api/attendance").send({
      studentId: "STU-102",
      status: "late"
    });

    const response = await request(app).get("/api/summary");

    expect(response.status).toBe(200);
    expect(response.body.data.total).toBe(1);
    expect(response.body.data.late).toBe(1);
  });

  test("POST /api/attendance rejects invalid payload", async () => {
    const response = await request(app)
      .post("/api/attendance")
      .send({
        studentId: "INVALID",
        status: "present"
      });

    expect(response.status).toBe(400);
    expect(response.body.error).toContain("Invalid studentId");
  });
});