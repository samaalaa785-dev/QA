/**
 * Admin Role – Backend Unit Tests
 * Framework : Jest
 * Stack     : Node.js · Express · Mongoose (MongoDB) · JWT
 *
 * All external dependencies (Mongoose models, bcrypt, jwt, nodemailer)
 * are mocked so tests run without a live database or network.
 *
 * Assumed API routes:
 *   POST   /api/admin/login
 *   GET    /api/admin/dashboard
 *   GET    /api/admin/users
 *   GET    /api/admin/workshops
 *   GET    /api/admin/bookings
 *   POST   /api/admin/registrations/:id/decide
 *   PATCH  /api/admin/services/:id/price
 *   POST   /api/admin/services
 *   PATCH  /api/admin/services/:id
 *   DELETE /api/admin/services/:id
 *   GET    /api/admin/activity
 */

'use strict';

// ── Jest auto-mock declarations ───────────────────────────────────────────────
jest.mock('../../src/models/Admin');
jest.mock('../../src/models/User');
jest.mock('../../src/models/Workshop');
jest.mock('../../src/models/Booking');
jest.mock('../../src/models/Service');
jest.mock('../../src/models/ActivityLog');
jest.mock('bcryptjs');
jest.mock('jsonwebtoken');

const bcrypt = require('bcryptjs');
const jwt    = require('jsonwebtoken');

const Admin       = require('../../src/models/Admin');
const User        = require('../../src/models/User');
const Workshop    = require('../../src/models/Workshop');
const Booking     = require('../../src/models/Booking');
const Service     = require('../../src/models/Service');
const ActivityLog = require('../../src/models/ActivityLog');

// Import the controller functions under test (pure functions – no HTTP layer)
// Adjust the paths to match your actual project layout.
const adminController = require('../../src/controllers/adminController');

// ── Mock data ─────────────────────────────────────────────────────────────────

const MOCK_ADMIN = {
  _id: 'admin-id-001',
  email: 'admin@salahny.com',
  passwordHash: '$2b$10$hashedPasswordMock',
  role: 'admin',
};

const MOCK_TOKEN = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.mock.signature';

const MOCK_USERS = [
  { _id: 'user-1', name: 'Mariam Yasser', email: 'mariam@example.com', phone: '01012345678', role: 'driver' },
  { _id: 'user-2', name: 'Ahmed Ali',    email: 'ahmed@example.com',   phone: '01098765432', role: 'driver' },
];

const MOCK_WORKSHOPS = [
  { _id: 'ws-1', name: 'Cairo Auto Care', specialty: 'Engine',  status: 'pending',  isVerified: false, totalJobs: 0 },
  { _id: 'ws-2', name: 'Alex Garage',     specialty: 'Tyres',   status: 'active',   isVerified: true,  totalJobs: 12 },
];

const MOCK_BOOKINGS = [
  { _id: 'bk-1', serviceName: 'Oil Change', driverName: 'Mariam', workshopName: 'Cairo Auto Care', status: 'active',    total: 450 },
  { _id: 'bk-2', serviceName: 'Tyre Check', driverName: 'Ahmed',  workshopName: 'Alex Garage',     status: 'completed', total: 200 },
];

const MOCK_SERVICES = [
  { _id: 'svc-1', name: 'Oil Change', category: 'maintenance', price: 150, isEnabled: true },
  { _id: 'svc-2', name: 'Tyre Check', category: 'tyres',        price: 100, isEnabled: true },
];

const MOCK_ACTIVITY = [
  { _id: 'log-1', actor: 'admin@salahny.com', action: 'login',           target: 'self',   timestamp: new Date() },
  { _id: 'log-2', actor: 'admin@salahny.com', action: 'approve_workshop', target: 'ws-1',  timestamp: new Date() },
];

// ── Helper – build a mock Express res object ──────────────────────────────────
const mockRes = () => {
  const res = {};
  res.status = jest.fn().mockReturnValue(res);
  res.json   = jest.fn().mockReturnValue(res);
  res.send   = jest.fn().mockReturnValue(res);
  return res;
};

// ── Helper – build a mock Express req object ─────────────────────────────────
const mockReq = (overrides = {}) => ({
  body:   {},
  params: {},
  query:  {},
  admin:  { id: MOCK_ADMIN._id, role: 'admin' }, // populated by auth middleware
  ...overrides,
});

// ─────────────────────────────────────────────────────────────────────────────
// 1. Admin login
// ─────────────────────────────────────────────────────────────────────────────
describe('POST /api/admin/login', () => {
  beforeEach(() => jest.clearAllMocks());

  // ── PASS ──────────────────────────────────────────────────────────────────

  test('PASS: returns 200 + JWT token for valid credentials', async () => {
    // Arrange
    Admin.findOne.mockResolvedValue(MOCK_ADMIN);
    bcrypt.compare.mockResolvedValue(true);
    jwt.sign.mockReturnValue(MOCK_TOKEN);

    const req = mockReq({ body: { email: 'admin@salahny.com', password: 'admin123' } });
    const res = mockRes();

    // Act
    await adminController.login(req, res);

    // Assert
    expect(Admin.findOne).toHaveBeenCalledWith({ email: 'admin@salahny.com' });
    expect(bcrypt.compare).toHaveBeenCalledWith('admin123', MOCK_ADMIN.passwordHash);
    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json).toHaveBeenCalledWith(
      expect.objectContaining({ token: MOCK_TOKEN, role: 'admin' }),
    );
  });

  test('PASS: returned token is the exact value produced by jwt.sign', async () => {
    Admin.findOne.mockResolvedValue(MOCK_ADMIN);
    bcrypt.compare.mockResolvedValue(true);
    jwt.sign.mockReturnValue('specific-test-token');

    const req = mockReq({ body: { email: 'admin@salahny.com', password: 'admin123' } });
    const res = mockRes();

    await adminController.login(req, res);

    const payload = res.json.mock.calls[0][0];
    expect(payload.token).toBe('specific-test-token');
  });

  // ── FAIL ──────────────────────────────────────────────────────────────────

  test('FAIL: returns 400 when email is missing from request body', async () => {
    const req = mockReq({ body: { password: 'admin123' } });
    const res = mockRes();

    await adminController.login(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(Admin.findOne).not.toHaveBeenCalled();
  });

  test('FAIL: returns 400 when password is missing from request body', async () => {
    const req = mockReq({ body: { email: 'admin@salahny.com' } });
    const res = mockRes();

    await adminController.login(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(Admin.findOne).not.toHaveBeenCalled();
  });

  test('FAIL: returns 400 when both fields are empty strings', async () => {
    const req = mockReq({ body: { email: '', password: '' } });
    const res = mockRes();

    await adminController.login(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  test('FAIL: returns 400 when email has no @ symbol', async () => {
    const req = mockReq({ body: { email: 'adminsalahny.com', password: 'admin123' } });
    const res = mockRes();

    await adminController.login(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  test('FAIL: returns 404 when admin account does not exist', async () => {
    Admin.findOne.mockResolvedValue(null);

    const req = mockReq({ body: { email: 'nobody@salahny.com', password: 'admin123' } });
    const res = mockRes();

    await adminController.login(req, res);

    expect(res.status).toHaveBeenCalledWith(404);
  });

  test('FAIL: returns 401 when password does not match hash', async () => {
    Admin.findOne.mockResolvedValue(MOCK_ADMIN);
    bcrypt.compare.mockResolvedValue(false);

    const req = mockReq({ body: { email: 'admin@salahny.com', password: 'wrongpassword' } });
    const res = mockRes();

    await adminController.login(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(jwt.sign).not.toHaveBeenCalled();
  });

  test('FAIL: returns 500 when database throws an unexpected error', async () => {
    Admin.findOne.mockRejectedValue(new Error('DB connection refused'));

    const req = mockReq({ body: { email: 'admin@salahny.com', password: 'admin123' } });
    const res = mockRes();

    await adminController.login(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 2. GET /api/admin/dashboard
// ─────────────────────────────────────────────────────────────────────────────
describe('GET /api/admin/dashboard', () => {
  beforeEach(() => jest.clearAllMocks());

  test('PASS: returns 200 with aggregated KPI snapshot', async () => {
    User.countDocuments.mockResolvedValue(2);
    Workshop.countDocuments
      .mockResolvedValueOnce(1)   // total workshops
      .mockResolvedValueOnce(2);  // pending approvals
    Booking.countDocuments.mockResolvedValue(5);
    Booking.aggregate.mockResolvedValue([{ total: 1250.0 }]);

    const req = mockReq();
    const res = mockRes();

    await adminController.getDashboard(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const body = res.json.mock.calls[0][0];
    expect(body).toMatchObject({
      drivers:          2,
      workshops:        1,
      bookings:         5,
      revenue:          1250.0,
      pendingApprovals: 2,
    });
  });

  test('PASS: returns zero revenue when no bookings exist', async () => {
    User.countDocuments.mockResolvedValue(0);
    Workshop.countDocuments.mockResolvedValue(0);
    Booking.countDocuments.mockResolvedValue(0);
    Booking.aggregate.mockResolvedValue([]);

    const req = mockReq();
    const res = mockRes();

    await adminController.getDashboard(req, res);

    const body = res.json.mock.calls[0][0];
    expect(body.revenue).toBe(0);
  });

  test('FAIL: returns 401 when auth middleware sets no admin context', async () => {
    const req = mockReq({ admin: null });
    const res = mockRes();

    await adminController.getDashboard(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(User.countDocuments).not.toHaveBeenCalled();
  });

  test('FAIL: returns 500 when a DB aggregation query throws', async () => {
    User.countDocuments.mockResolvedValue(2);
    Workshop.countDocuments.mockResolvedValue(1);
    Booking.countDocuments.mockResolvedValue(3);
    Booking.aggregate.mockRejectedValue(new Error('aggregation failed'));

    const req = mockReq();
    const res = mockRes();

    await adminController.getDashboard(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 3. GET /api/admin/users
// ─────────────────────────────────────────────────────────────────────────────
describe('GET /api/admin/users', () => {
  beforeEach(() => jest.clearAllMocks());

  test('PASS: returns 200 with array of driver users', async () => {
    User.find.mockResolvedValue(MOCK_USERS);

    const req = mockReq();
    const res = mockRes();

    await adminController.getUsers(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const body = res.json.mock.calls[0][0];
    expect(Array.isArray(body)).toBe(true);
    expect(body).toHaveLength(2);
    expect(body[0].name).toBe('Mariam Yasser');
  });

  test('PASS: returns 200 with empty array when no users exist', async () => {
    User.find.mockResolvedValue([]);

    const req = mockReq();
    const res = mockRes();

    await adminController.getUsers(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json.mock.calls[0][0]).toEqual([]);
  });

  test('FAIL: returns 401 when request is unauthenticated', async () => {
    const req = mockReq({ admin: null });
    const res = mockRes();

    await adminController.getUsers(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(User.find).not.toHaveBeenCalled();
  });

  test('FAIL: returns 500 when DB query throws', async () => {
    User.find.mockRejectedValue(new Error('timeout'));

    const req = mockReq();
    const res = mockRes();

    await adminController.getUsers(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 4. GET /api/admin/workshops
// ─────────────────────────────────────────────────────────────────────────────
describe('GET /api/admin/workshops', () => {
  beforeEach(() => jest.clearAllMocks());

  test('PASS: returns 200 with workshop list', async () => {
    Workshop.find.mockResolvedValue(MOCK_WORKSHOPS);

    const req = mockReq();
    const res = mockRes();

    await adminController.getWorkshops(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json.mock.calls[0][0]).toHaveLength(2);
  });

  test('PASS: only verified workshops filter when query param provided', async () => {
    const verified = MOCK_WORKSHOPS.filter(w => w.isVerified);
    Workshop.find.mockResolvedValue(verified);

    const req = mockReq({ query: { verified: 'true' } });
    const res = mockRes();

    await adminController.getWorkshops(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const body = res.json.mock.calls[0][0];
    expect(body.every(w => w.isVerified)).toBe(true);
  });

  test('PASS: empty list returned when no workshops exist', async () => {
    Workshop.find.mockResolvedValue([]);

    const req = mockReq();
    const res = mockRes();

    await adminController.getWorkshops(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json.mock.calls[0][0]).toEqual([]);
  });

  test('FAIL: returns 401 for unauthenticated request', async () => {
    const req = mockReq({ admin: null });
    const res = mockRes();

    await adminController.getWorkshops(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
  });

  test('FAIL: returns 500 when DB query fails', async () => {
    Workshop.find.mockRejectedValue(new Error('network error'));

    const req = mockReq();
    const res = mockRes();

    await adminController.getWorkshops(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 5. GET /api/admin/bookings
// ─────────────────────────────────────────────────────────────────────────────
describe('GET /api/admin/bookings', () => {
  beforeEach(() => jest.clearAllMocks());

  test('PASS: returns 200 with all bookings', async () => {
    Booking.find.mockResolvedValue(MOCK_BOOKINGS);

    const req = mockReq();
    const res = mockRes();

    await adminController.getBookings(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json.mock.calls[0][0]).toHaveLength(2);
  });

  test('PASS: returns only active bookings when status filter is applied', async () => {
    Booking.find.mockResolvedValue(MOCK_BOOKINGS.filter(b => b.status === 'active'));

    const req = mockReq({ query: { status: 'active' } });
    const res = mockRes();

    await adminController.getBookings(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const body = res.json.mock.calls[0][0];
    expect(body.every(b => b.status === 'active')).toBe(true);
  });

  test('PASS: returns empty array when no bookings match the filter', async () => {
    Booking.find.mockResolvedValue([]);

    const req = mockReq({ query: { status: 'cancelled' } });
    const res = mockRes();

    await adminController.getBookings(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json.mock.calls[0][0]).toEqual([]);
  });

  test('FAIL: returns 401 for unauthenticated request', async () => {
    const req = mockReq({ admin: null });
    const res = mockRes();

    await adminController.getBookings(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(Booking.find).not.toHaveBeenCalled();
  });

  test('FAIL: returns 500 when DB query throws', async () => {
    Booking.find.mockRejectedValue(new Error('DB error'));

    const req = mockReq();
    const res = mockRes();

    await adminController.getBookings(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 6. POST /api/admin/registrations/:id/decide
// ─────────────────────────────────────────────────────────────────────────────
describe('POST /api/admin/registrations/:id/decide', () => {
  const pendingWorkshop = {
    _id: 'ws-1',
    name: 'Cairo Auto Care',
    status: 'pending',
    save: jest.fn().mockResolvedValue(true),
  };

  beforeEach(() => jest.clearAllMocks());

  test('PASS: accepting a pending registration returns 200 and saves status=active', async () => {
    Workshop.findById.mockResolvedValue({ ...pendingWorkshop, save: jest.fn().mockResolvedValue(true) });

    const req = mockReq({ params: { id: 'ws-1' }, body: { decision: 'accept' } });
    const res = mockRes();

    await adminController.decideRegistration(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const body = res.json.mock.calls[0][0];
    expect(body.status).toBe('active');
  });

  test('PASS: rejecting a pending registration returns 200 and saves status=rejected', async () => {
    Workshop.findById.mockResolvedValue({ ...pendingWorkshop, save: jest.fn().mockResolvedValue(true) });

    const req = mockReq({ params: { id: 'ws-1' }, body: { decision: 'reject' } });
    const res = mockRes();

    await adminController.decideRegistration(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const body = res.json.mock.calls[0][0];
    expect(body.status).toBe('rejected');
  });

  test('FAIL: returns 400 when decision value is missing from body', async () => {
    const req = mockReq({ params: { id: 'ws-1' }, body: {} });
    const res = mockRes();

    await adminController.decideRegistration(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(Workshop.findById).not.toHaveBeenCalled();
  });

  test('FAIL: returns 400 when decision value is invalid (not accept/reject)', async () => {
    const req = mockReq({ params: { id: 'ws-1' }, body: { decision: 'maybe' } });
    const res = mockRes();

    await adminController.decideRegistration(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  test('FAIL: returns 404 when the registration ID does not exist', async () => {
    Workshop.findById.mockResolvedValue(null);

    const req = mockReq({ params: { id: 'nonexistent' }, body: { decision: 'accept' } });
    const res = mockRes();

    await adminController.decideRegistration(req, res);

    expect(res.status).toHaveBeenCalledWith(404);
  });

  test('FAIL: returns 409 when registration is already decided (not pending)', async () => {
    Workshop.findById.mockResolvedValue({
      _id: 'ws-2',
      status: 'active',
      save: jest.fn(),
    });

    const req = mockReq({ params: { id: 'ws-2' }, body: { decision: 'accept' } });
    const res = mockRes();

    await adminController.decideRegistration(req, res);

    expect(res.status).toHaveBeenCalledWith(409);
  });

  test('FAIL: returns 401 for unauthenticated request', async () => {
    const req = mockReq({ admin: null, params: { id: 'ws-1' }, body: { decision: 'accept' } });
    const res = mockRes();

    await adminController.decideRegistration(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
  });

  test('FAIL: returns 500 when DB save throws', async () => {
    Workshop.findById.mockResolvedValue({
      ...pendingWorkshop,
      save: jest.fn().mockRejectedValue(new Error('write conflict')),
    });

    const req = mockReq({ params: { id: 'ws-1' }, body: { decision: 'accept' } });
    const res = mockRes();

    await adminController.decideRegistration(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 7. PATCH /api/admin/services/:id/price
// ─────────────────────────────────────────────────────────────────────────────
describe('PATCH /api/admin/services/:id/price', () => {
  beforeEach(() => jest.clearAllMocks());

  const existingService = {
    _id: 'svc-1',
    name: 'Oil Change',
    price: 150,
    save: jest.fn().mockResolvedValue(true),
  };

  test('PASS: updates price for an existing service', async () => {
    Service.findById.mockResolvedValue({ ...existingService, save: jest.fn().mockResolvedValue(true) });

    const req = mockReq({ params: { id: 'svc-1' }, body: { price: 180 } });
    const res = mockRes();

    await adminController.updateServicePrice(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const body = res.json.mock.calls[0][0];
    expect(body.price).toBe(180);
  });

  test('PASS: decimal price (99.99) is stored correctly', async () => {
    Service.findById.mockResolvedValue({ ...existingService, save: jest.fn().mockResolvedValue(true) });

    const req = mockReq({ params: { id: 'svc-1' }, body: { price: 99.99 } });
    const res = mockRes();

    await adminController.updateServicePrice(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json.mock.calls[0][0].price).toBe(99.99);
  });

  test('FAIL: returns 400 when price is 0', async () => {
    const req = mockReq({ params: { id: 'svc-1' }, body: { price: 0 } });
    const res = mockRes();

    await adminController.updateServicePrice(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(Service.findById).not.toHaveBeenCalled();
  });

  test('FAIL: returns 400 when price is negative', async () => {
    const req = mockReq({ params: { id: 'svc-1' }, body: { price: -50 } });
    const res = mockRes();

    await adminController.updateServicePrice(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  test('FAIL: returns 400 when price field is missing', async () => {
    const req = mockReq({ params: { id: 'svc-1' }, body: {} });
    const res = mockRes();

    await adminController.updateServicePrice(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  test('FAIL: returns 404 when service ID does not exist', async () => {
    Service.findById.mockResolvedValue(null);

    const req = mockReq({ params: { id: 'ghost-id' }, body: { price: 200 } });
    const res = mockRes();

    await adminController.updateServicePrice(req, res);

    expect(res.status).toHaveBeenCalledWith(404);
  });

  test('FAIL: returns 401 for unauthenticated request', async () => {
    const req = mockReq({ admin: null, params: { id: 'svc-1' }, body: { price: 200 } });
    const res = mockRes();

    await adminController.updateServicePrice(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 8. POST /api/admin/services  (create)
// ─────────────────────────────────────────────────────────────────────────────
describe('POST /api/admin/services', () => {
  beforeEach(() => jest.clearAllMocks());

  const newServiceBody = {
    name:        'Brake Pad Replacement',
    category:    'brakes',
    price:       350,
    durationMins: 60,
    description: 'Full brake pad replacement on all four wheels',
    isEnabled:   true,
  };

  test('PASS: creates and returns new service with 201', async () => {
    const savedDoc = { _id: 'svc-new', ...newServiceBody };
    Service.create.mockResolvedValue(savedDoc);

    const req = mockReq({ body: newServiceBody });
    const res = mockRes();

    await adminController.createService(req, res);

    expect(res.status).toHaveBeenCalledWith(201);
    expect(res.json.mock.calls[0][0]._id).toBe('svc-new');
  });

  test('FAIL: returns 400 when name is missing', async () => {
    const req = mockReq({ body: { ...newServiceBody, name: undefined } });
    const res = mockRes();

    await adminController.createService(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(Service.create).not.toHaveBeenCalled();
  });

  test('FAIL: returns 400 when price is missing', async () => {
    const req = mockReq({ body: { ...newServiceBody, price: undefined } });
    const res = mockRes();

    await adminController.createService(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  test('FAIL: returns 400 when name is an empty string', async () => {
    const req = mockReq({ body: { ...newServiceBody, name: '' } });
    const res = mockRes();

    await adminController.createService(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
  });

  test('FAIL: returns 409 when a service with the same name already exists', async () => {
    Service.findOne.mockResolvedValue(MOCK_SERVICES[0]);

    const req = mockReq({ body: { ...newServiceBody, name: 'Oil Change' } });
    const res = mockRes();

    await adminController.createService(req, res);

    expect(res.status).toHaveBeenCalledWith(409);
    expect(Service.create).not.toHaveBeenCalled();
  });

  test('FAIL: returns 401 for unauthenticated request', async () => {
    const req = mockReq({ admin: null, body: newServiceBody });
    const res = mockRes();

    await adminController.createService(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
  });

  test('FAIL: returns 500 when DB create throws', async () => {
    Service.findOne.mockResolvedValue(null);
    Service.create.mockRejectedValue(new Error('DB write failed'));

    const req = mockReq({ body: newServiceBody });
    const res = mockRes();

    await adminController.createService(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 9. PATCH /api/admin/services/:id  (edit)
// ─────────────────────────────────────────────────────────────────────────────
describe('PATCH /api/admin/services/:id', () => {
  beforeEach(() => jest.clearAllMocks());

  test('PASS: updates name and price of existing service', async () => {
    const doc = { _id: 'svc-1', name: 'Oil Change', price: 150, save: jest.fn().mockResolvedValue(true) };
    Service.findById.mockResolvedValue(doc);

    const req = mockReq({
      params: { id: 'svc-1' },
      body: { name: 'Synthetic Oil Change', price: 200 },
    });
    const res = mockRes();

    await adminController.updateService(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const body = res.json.mock.calls[0][0];
    expect(body.name).toBe('Synthetic Oil Change');
    expect(body.price).toBe(200);
  });

  test('PASS: toggling isEnabled to false is a valid update', async () => {
    const doc = { _id: 'svc-1', name: 'Oil Change', price: 150, isEnabled: true, save: jest.fn().mockResolvedValue(true) };
    Service.findById.mockResolvedValue(doc);

    const req = mockReq({ params: { id: 'svc-1' }, body: { isEnabled: false } });
    const res = mockRes();

    await adminController.updateService(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json.mock.calls[0][0].isEnabled).toBe(false);
  });

  test('FAIL: returns 404 when service does not exist', async () => {
    Service.findById.mockResolvedValue(null);

    const req = mockReq({ params: { id: 'ghost' }, body: { name: 'X' } });
    const res = mockRes();

    await adminController.updateService(req, res);

    expect(res.status).toHaveBeenCalledWith(404);
  });

  test('FAIL: returns 400 when update body sends a negative price', async () => {
    const req = mockReq({ params: { id: 'svc-1' }, body: { price: -10 } });
    const res = mockRes();

    await adminController.updateService(req, res);

    expect(res.status).toHaveBeenCalledWith(400);
    expect(Service.findById).not.toHaveBeenCalled();
  });

  test('FAIL: returns 401 for unauthenticated request', async () => {
    const req = mockReq({ admin: null, params: { id: 'svc-1' }, body: { name: 'X' } });
    const res = mockRes();

    await adminController.updateService(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 10. DELETE /api/admin/services/:id
// ─────────────────────────────────────────────────────────────────────────────
describe('DELETE /api/admin/services/:id', () => {
  beforeEach(() => jest.clearAllMocks());

  test('PASS: deletes existing service and returns 200', async () => {
    Service.findByIdAndDelete.mockResolvedValue(MOCK_SERVICES[0]);

    const req = mockReq({ params: { id: 'svc-1' } });
    const res = mockRes();

    await adminController.deleteService(req, res);

    expect(Service.findByIdAndDelete).toHaveBeenCalledWith('svc-1');
    expect(res.status).toHaveBeenCalledWith(200);
  });

  test('PASS: response body confirms deleted service ID', async () => {
    Service.findByIdAndDelete.mockResolvedValue(MOCK_SERVICES[0]);

    const req = mockReq({ params: { id: 'svc-1' } });
    const res = mockRes();

    await adminController.deleteService(req, res);

    const body = res.json.mock.calls[0][0];
    expect(body.deleted).toBe('svc-1');
  });

  test('FAIL: returns 404 when service does not exist', async () => {
    Service.findByIdAndDelete.mockResolvedValue(null);

    const req = mockReq({ params: { id: 'ghost-svc' } });
    const res = mockRes();

    await adminController.deleteService(req, res);

    expect(res.status).toHaveBeenCalledWith(404);
  });

  test('FAIL: returns 401 for unauthenticated request', async () => {
    const req = mockReq({ admin: null, params: { id: 'svc-1' } });
    const res = mockRes();

    await adminController.deleteService(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(Service.findByIdAndDelete).not.toHaveBeenCalled();
  });

  test('FAIL: returns 500 when DB delete throws', async () => {
    Service.findByIdAndDelete.mockRejectedValue(new Error('lock timeout'));

    const req = mockReq({ params: { id: 'svc-1' } });
    const res = mockRes();

    await adminController.deleteService(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});

// ─────────────────────────────────────────────────────────────────────────────
// 11. GET /api/admin/activity
// ─────────────────────────────────────────────────────────────────────────────
describe('GET /api/admin/activity', () => {
  beforeEach(() => jest.clearAllMocks());

  test('PASS: returns 200 with activity log entries sorted by newest first', async () => {
    ActivityLog.find.mockReturnValue({
      sort: jest.fn().mockReturnValue({
        limit: jest.fn().mockResolvedValue(MOCK_ACTIVITY),
      }),
    });

    const req = mockReq();
    const res = mockRes();

    await adminController.getActivity(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    const body = res.json.mock.calls[0][0];
    expect(body).toHaveLength(2);
    expect(body[0].action).toBe('login');
  });

  test('PASS: returns empty array when no activity logs exist', async () => {
    ActivityLog.find.mockReturnValue({
      sort: jest.fn().mockReturnValue({
        limit: jest.fn().mockResolvedValue([]),
      }),
    });

    const req = mockReq();
    const res = mockRes();

    await adminController.getActivity(req, res);

    expect(res.status).toHaveBeenCalledWith(200);
    expect(res.json.mock.calls[0][0]).toEqual([]);
  });

  test('FAIL: returns 401 for unauthenticated request', async () => {
    const req = mockReq({ admin: null });
    const res = mockRes();

    await adminController.getActivity(req, res);

    expect(res.status).toHaveBeenCalledWith(401);
    expect(ActivityLog.find).not.toHaveBeenCalled();
  });

  test('FAIL: returns 500 when DB query throws', async () => {
    ActivityLog.find.mockReturnValue({
      sort: jest.fn().mockReturnValue({
        limit: jest.fn().mockRejectedValue(new Error('cursor error')),
      }),
    });

    const req = mockReq();
    const res = mockRes();

    await adminController.getActivity(req, res);

    expect(res.status).toHaveBeenCalledWith(500);
  });
});