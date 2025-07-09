//app.js
const express = require('express');
const mysql = require('mysql2/promise');
const cors = require('cors');
const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');

const app = express();
const port = 3000;

// Database connection
const connection = mysql.createPool({
    host: 'localhost',
    user: 'root',
    password: '',
    database: 'mobile_pro',
    waitForConnections: true,
    connectionLimit: 10,
})

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

const JWT_KEY = '123';

// Utility function to handle errors
const handleError = (res, error) => {
    console.error(error);
    res.status(500).json({ error: 'Internal Server Error' });
};

function verifyUser(req, res, next) {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    if (token == undefined || token == null) {
        // no token
        return res.status(400).send('No token');
    }

    // token found
    if (req.headers.authorization) {
        const tokenString = token.split(' ');
        if (tokenString[0] == 'Bearer') {
            token = tokenString[1];
        }
    }
    jwt.verify(token, JWT_KEY, (err, decoded) => {
        if (err) {
            res.status(401).send('Incorrect token');
        }
        else if (decoded.role != 'user') {
            res.status(403).send('Forbidden to access the data');
        }
        else {
            req.decoded = decoded;
            next();
        }
    });
}

function verifyToken(req, res, next) {
    let token = req.headers['authorization'] || req.headers['x-access-token'];
    if (!token) {
        return res.status(400).send('No token');
    }

    if (req.headers.authorization) {
        const tokenString = token.split(' ');
        if (tokenString[0] === 'Bearer') {
            token = tokenString[1];
        }
    }

    jwt.verify(token, JWT_KEY, (err, decoded) => {
        if (err) {
            return res.status(401).send('Invalid token');
        }
        req.decoded = decoded;
        next();
    });
}

// Login
app.post('/login', async (req, res) => {
    const { email, password } = req.body;

    try {
        const [results] = await connection.execute(
            'SELECT user_id, role, first_name, last_name, email, password FROM users WHERE email = ?',
            [email]
        );

        if (results.length === 0) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }

        const user = results[0];
        const passwordMatches = await bcrypt.compare(password, user.password);
        if (!passwordMatches) {
            return res.status(401).json({ message: 'Invalid email or password' });
        }
        const payload = {
            userId: String(user.user_id),
            role: user.role,
            firstName: user.first_name,
            lastName: user.last_name,
            email: user.email
        };

        const token = jwt.sign(payload, JWT_KEY, { expiresIn: '1d' });

        return res.send(token);

    } catch (error) {
        return handleError(res, error);
    }
});

app.get('/profile', verifyToken, async (req, res) => {
    const userId = req.decoded.userId;

    try {
        const [user] = await connection.execute(
            'SELECT user_id, email, first_name, last_name, phone_number FROM users WHERE user_id = ?',
            [userId]
        );

        if (user.length === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.status(200).json(user[0]);
    } catch (error) {
        handleError(res, error);
    }
});

app.put('/profile', verifyUser, async (req, res) => {
    const userId = req.decoded.userId;
    const { email, first_name, last_name, phone_number } = req.body;

    try {
        const [result] = await connection.execute(
            'UPDATE users SET email = ?, first_name = ?, last_name = ?, phone_number = ? WHERE user_id = ?',
            [email, first_name, last_name, phone_number, userId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: 'User not found' });
        }

        res.status(200).json({ message: 'Profile updated successfully' });
    } catch (error) {
        handleError(res, error);
    }
});

// Browseroom User
app.get('/browseroom_user', async (req, res) => {
    const query = 'SELECT room_id, room_name, room_img, first_slot, second_slot, third_slot, fourth_slot, room_status FROM rooms';

    try {
        const [results] = await connection.execute(query);
        res.json(results);
    } catch (err) {
        console.error('Error fetching rooms: ' + err.stack);
        return res.status(500).send('Error fetching rooms');
    }
});


// Browseroom Lecturer
app.get('/browseroom_lecturer', async (req, res) => {
    const query = 'SELECT room_name, room_img, first_slot, second_slot, third_slot, fourth_slot, room_status FROM rooms';

    try {
        const [results] = await connection.execute(query);
        res.json(results);
    } catch (err) {
        console.error('Error fetching rooms: ' + err.stack);
        return res.status(500).send('Error fetching rooms');
    }
});

// Browseroom Staff
app.get('/browseroom_staff', async (req, res) => {
    const query = 'SELECT room_name, room_img, location, bed, room_status, room_id FROM rooms';

    try {
        const [rows] = await connection.query(query);
        res.json(rows);
    } catch (error) {
        handleError(res, error);
    }
});

// Disable Room
app.put('/disableRoom/:room_id', async (req, res) => {
    const { room_id } = req.params; // เปลี่ยน room_id เป็น room_name หรือค่าที่ถูกต้อง
    const query = 'UPDATE rooms SET room_status = "disabled",first_slot = "disabled",second_slot = "disabled",third_slot = "disabled", fourth_slot = "disabled" WHERE room_id = ?';

    try {
        const [result] = await connection.execute(query, [room_id]);
        if (result.affectedRows > 0) {
            res.json({ message: 'Room disabled successfully' });
        } else {
            res.status(404).json({ message: 'Room not found' });
        }
    } catch (error) {
        handleError(res, error);
    }
});

// Enable Room
app.put('/enableRoom/:room_id', async (req, res) => {
    const { room_id } = req.params; // เปลี่ยน room_id เป็น room_name หรือค่าที่ถูกต้อง
    const query = 'UPDATE rooms SET room_status = "enabled",first_slot = "free",second_slot = "free",third_slot = "free", fourth_slot = "free" WHERE room_id = ?';

    try {
        const [result] = await connection.execute(query, [room_id]);
        if (result.affectedRows > 0) {
            res.json({ message: 'Room enabled successfully' });
        } else {
            res.status(404).json({ message: 'Room not found' });
        }
    } catch (error) {
        handleError(res, error);
    }
});

// Edit
app.put('/edit/:room_id', async (req, res) => {
    const room_id = req.params.room_id;
    const { room_img, room_name, bed, location } = req.body;

    const sql = 'UPDATE rooms SET room_img = ?, room_name = ?, bed = ?, location = ? WHERE room_id = ?';

    try {
        const [result] = await connection.execute(sql, [room_img, room_name, bed, location, room_id]);
        if (result.affectedRows === 0) {
            return res.status(404).json({ success: false, message: 'Room not found' });
        }
        res.status(200).json({ success: true, message: 'Room details have been updated.' });
    } catch (err) {
        console.error(err);
        return res.status(500).json({ success: false, message: 'Database server error' });
    }
});

// Add
app.post('/add', async (req, res) => {
    const { room_img, room_name, bed, location } = req.body;

    const sql = 'INSERT INTO rooms (room_img, room_name, bed, location) VALUES (?, ?, ?, ?)';

    try {
        const [result] = await connection.execute(sql, [room_img, room_name, bed, location]);

        if (result.affectedRows > 0) {
            res.status(201).json({ success: true, message: 'Room has been added successfully.' });
        } else {
            res.status(400).json({ success: false, message: 'Failed to add room.' });
        }
    } catch (err) {
        console.error(err);
        return res.status(500).json({ success: false, message: 'Database server error' });
    }
});

// Route to get room details and include them in the token
app.get('/roomDetails/:room_id', verifyToken, async (req, res) => {
    const { room_id } = req.params;

    try {
        // Query the rooms table for room details based on room_id
        const query = `SELECT room_name, location, bed, room_img, room_status FROM rooms WHERE room_id = ?`;
        const [roomDetails] = await connection.execute(query, [room_id]);

        if (roomDetails.length === 0) {
            return res.status(404).json({ success: false, message: 'Room not found' });
        }

        // Send the room details in the response
        res.status(200).json({
            room_name: roomDetails[0].room_name,
            location: roomDetails[0].location,
            bed: roomDetails[0].bed,
            room_img: roomDetails[0].room_img,
            room_status: roomDetails[0].room_status
        });

    } catch (error) {
        console.error('Error fetching room details:', error);
        res.status(500).json({ success: false, message: 'An error occurred while fetching room details' });
    }
});



// Request to Book
// Request to Book
app.post('/requestBook', verifyToken, async (req, res) => {
    const { room_id, start_time, end_time, date } = req.body;
    const user_id = req.decoded.userId;

    if (!user_id || !room_id || !start_time || !end_time || !date) {
        return res.status(400).json({ success: false, message: 'Missing required fields' });
    }

    const SLOT_MAPPING = {
        '08:00:00-10:00:00': 'first_slot',
        '10:00:00-12:00:00': 'second_slot',
        '13:00:00-15:00:00': 'third_slot',
        '15:00:00-17:00:00': 'fourth_slot'
    };
    const slotColumn = SLOT_MAPPING[`${start_time}-${end_time}`];
    if (!slotColumn) {
        return res.status(400).json({ success: false, message: 'Invalid time slot requested' });
    }

    let singleConnection;
    try {
        singleConnection = await connection.getConnection();
        await singleConnection.beginTransaction();

        // Check if the user has any pending bookings for the same date
        const [pendingBookings] = await singleConnection.execute(
            'SELECT * FROM bookings WHERE user_id = ? AND status = "pending" AND date = ?',
            [user_id, date]
        );

        if (pendingBookings.length > 0) {
            return res.status(400).json({ success: false, message: 'You already have a pending booking for this date. Please wait for it to be processed.' });
        }

        const roomQuery = `SELECT room_status, ${slotColumn} AS slot_status FROM rooms WHERE room_id = ?`;
        const [roomCheck] = await singleConnection.execute(roomQuery, [room_id]);

        if (roomCheck.length === 0) {
            return res.status(404).json({ success: false, message: 'Room not found' });
        }

        const { room_status, slot_status } = roomCheck[0];
        if (room_status === 'disabled') {
            return res.status(400).json({ success: false, message: 'Room is currently disabled' });
        }

        if (slot_status !== 'free') {
            return res.status(400).json({ success: false, message: 'Selected time slot is not available' });
        }

        // Proceed to create a new booking
        const [bookingResult] = await singleConnection.execute(
            'INSERT INTO bookings (user_id, room_id, start_time, end_time, date, status) VALUES (?, ?, ?, ?, ?, "pending")',
            [user_id, room_id, start_time, end_time, date]
        );

        const updateQuery = `UPDATE rooms SET ${slotColumn} = 'pending' WHERE room_id = ?`;
        await singleConnection.execute(updateQuery, [room_id]);

        await singleConnection.commit();

        const token = req.headers['authorization'] || req.headers['x-access-token'];
        res.status(201).json({
            success: true,
            message: 'Booking request submitted successfully',
            booking_id: bookingResult.insertId,
            token: token
        });

    } catch (error) {
        if (singleConnection) await singleConnection.rollback();
        console.error('Error creating booking:', error);
        res.status(500).json({ success: false, message: 'An error occurred while processing your request' });
    } finally {
        if (singleConnection) await singleConnection.release();
    }
});


// Reset all room slots at midnight
app.put('/resetSlots', async (req, res) => {
    const resetQuery = `
        UPDATE rooms
        SET room_status = 'enabled',
            first_slot = 'free',
            second_slot = 'free',
            third_slot = 'free',
            fourth_slot = 'free'
    `;

    try {
        const [result] = await connection.execute(resetQuery);

        // Check if any rows were affected (rooms updated)
        if (result.affectedRows > 0) {
            res.status(200).json({ message: 'All room slots have been reset to free' });
        } else {
            res.status(404).json({ message: 'No rooms found to reset' });
        }
    } catch (error) {
        console.error('Error resetting room slots:', error.message);
        res.status(500).json({ error: 'Internal Server Error' });
    }
});


app.put('/updatePendingBookings', async (req, res) => {
    const { date } = req.body; // Expect 'date' from the frontend in the format 'YYYY-MM-DD'
    const SLOT_MAPPING = {
        '08:00:00-10:00:00': 'first_slot',
        '10:00:00-12:00:00': 'second_slot',
        '13:00:00-15:00:00': 'third_slot',
        '15:00:00-17:00:00': 'fourth_slot'
    };

    try {
        // Query for pending bookings on the specified date
        const [pendingBookings] = await connection.execute(
            'SELECT booking_id, room_id, start_time, end_time FROM bookings WHERE status = "pending" AND date = ?',
            [date]
        );

        if (pendingBookings.length === 0) {
            return res.status(404).json({ message: 'No pending bookings found for the given date' });
        }

        // Process each pending booking
        for (const booking of pendingBookings) {
            // Determine the correct slot column for the time range
            const slotColumn = SLOT_MAPPING[`${booking.start_time}-${booking.end_time}`];
            if (!slotColumn) {
                console.error(`Invalid time slot for booking ID ${booking.booking_id}`);
                continue; // Skip if the time slot doesn't match SLOT_MAPPING
            }

            // Check the current status of the specified slot in the room
            const [roomStatus] = await connection.execute(
                `SELECT ${slotColumn} FROM rooms WHERE room_id = ?`,
                [booking.room_id]
            );

            // Skip updating if the slot is currently 'disabled'
            if (roomStatus[0][slotColumn] === 'disabled') {
                //console.log(`Skipping update for room ID ${booking.room_id}, ${slotColumn} is disabled`);
                continue; // Move to the next booking
            }

            // Update the slot status to 'pending' if it is not 'disabled'
            await connection.execute(
                `UPDATE rooms SET ${slotColumn} = 'pending' WHERE room_id = ?`,
                [booking.room_id]
            );
        }

        res.status(200).json({ message: 'Pending bookings processed and room slots updated' });
    } catch (error) {
        console.error('Error updating pending bookings:', error);
        res.status(500).json({ message: 'An error occurred while processing pending bookings' });
    }
});

app.put('/updateApprovedBookings', async (req, res) => {
    const { date } = req.body;
    const SLOT_MAPPING = {
        '08:00:00-10:00:00': 'first_slot',
        '10:00:00-12:00:00': 'second_slot',
        '13:00:00-15:00:00': 'third_slot',
        '15:00:00-17:00:00': 'fourth_slot'
    };

    try {
        const [approvedBookings] = await connection.execute(
            'SELECT booking_id, room_id, start_time, end_time FROM bookings WHERE status = "approved" AND date = ?',
            [date]
        );

        if (approvedBookings.length === 0) {
            return res.status(404).json({ message: 'No approved bookings found for the given date' });
        }

        for (const booking of approvedBookings) {
            const slotColumn = SLOT_MAPPING[`${booking.start_time}-${booking.end_time}`];
            if (!slotColumn) {
                console.error(`Invalid time slot for booking ID ${booking.booking_id}`);
            }

            const [roomStatus] = await connection.execute(
                `SELECT ${slotColumn} FROM rooms WHERE room_id = ?`,
                [booking.room_id]
            );
            if (roomStatus[0][slotColumn] === 'disabled') {
                //console.log(`Skipping update for room ID ${booking.room_id}, ${slotColumn} is disabled`);
                continue; // Move to the next booking
            }

            await connection.execute(
                `UPDATE rooms SET ${slotColumn} = 'reserved' WHERE room_id = ?`,
                [booking.room_id]
            );
        }

        res.status(200).json({ message: 'Approved bookings processed and room slots updated' });
    } catch (error) {
        console.error('Error updating Approved bookings:', error);
        res.status(500).json({ message: 'An error occurred while processing Approved bookings' });
    }
});

// See booking reqest
app.get('/seebookingReq', async (req, res) => {
    const sql = `
      SELECT 
        b.booking_id AS BookingID,
        CONCAT(u.first_name, ' ', u.last_name) AS Name, 
        r.room_name AS Room, 
        b.start_time AS StartTime, 
        b.end_time AS EndTime, 
        b.date AS Date 
      FROM 
        bookings b
      JOIN 
        users u ON b.user_id = u.user_id
      JOIN 
        rooms r ON b.room_id = r.room_id
      WHERE 
        b.status = 'pending'
    `;

    try {
        const [results] = await connection.execute(sql); // Corrected connection usage
        if (results.length === 0) {
            return res.status(404).json({ message: 'No pending bookings found.' });
        }
        res.json(results);

    } catch (error) {
        console.error('Error fetching data:', error.message);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// Approve
app.post('/approve/:booking_id', async (req, res) => {
    const approver_id = req.body.approver_id || 11;// ตั้งค่า default เป็น 11 หาก approver_id เป็น undefined
    const bookingId = req.params.booking_id;
    const sqlStatus = 'approved';

    const sqlUpdateBooking = `
      UPDATE bookings 
      SET status = ?, approver_id = ?
      WHERE booking_id = ?
    `;

    const sqlGetBookingDetails = `
      SELECT room_id, start_time, end_time 
      FROM bookings 
      WHERE booking_id = ?
    `;

    try {
        // อัปเดต booking status และ approver_id
        const [results] = await connection.execute(sqlUpdateBooking, [sqlStatus, approver_id, bookingId]);

        if (results.affectedRows > 0) {
            // ดึงรายละเอียด booking เพื่อหาช่วงเวลาสำหรับปรับ slot ของห้อง
            const [bookingDetails] = await connection.execute(sqlGetBookingDetails, [bookingId]);
            if (bookingDetails.length > 0) {
                const { room_id, start_time, end_time } = bookingDetails[0];
                let slotColumn;

                // กำหนด slotColumn ตามช่วงเวลา start_time และ end_time
                if (start_time === '08:00:00' && end_time === '10:00:00') {
                    slotColumn = 'first_slot';
                } else if (start_time === '10:00:00' && end_time === '12:00:00') {
                    slotColumn = 'second_slot';
                } else if (start_time === '13:00:00' && end_time === '15:00:00') {
                    slotColumn = 'third_slot';
                } else if (start_time === '15:00:00' && end_time === '17:00:00') {
                    slotColumn = 'fourth_slot';
                }

                if (slotColumn) {
                    const sqlUpdateRoomSlot = `
                      UPDATE rooms
                      SET ${slotColumn} = 'reserved'
                      WHERE room_id = ?
                    `;
                    await connection.execute(sqlUpdateRoomSlot, [room_id]);
                }

                res.json({ message: 'Booking and room slot updated successfully' });
            } else {
                res.status(404).json({ message: 'Booking details not found' });
            }
        } else {
            res.status(404).json({ message: 'Booking not found' });
        }
    } catch (error) {
        console.error('Error updating booking:', error.message);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});



// Disapprove
app.post('/disapprove/:booking_id', async (req, res) => {
    const approver_id = req.body.approver_id || 11; // ตั้งค่า default เป็น 11 หาก approver_id เป็น undefined
    const bookingId = req.params.booking_id;
    const sqlStatus = 'rejected';

    const sqlUpdateBooking = `
      UPDATE bookings 
      SET status = ?, approver_id = ?
      WHERE booking_id = ?
    `;

    const sqlGetBookingDetails = `
      SELECT room_id, start_time, end_time 
      FROM bookings 
      WHERE booking_id = ?
    `;

    try {
        // อัปเดต booking status และ approver_id
        const [results] = await connection.execute(sqlUpdateBooking, [sqlStatus, approver_id, bookingId]);

        if (results.affectedRows > 0) {
            // ดึงรายละเอียด booking เพื่อหาช่วงเวลาสำหรับปรับ slot ของห้อง
            const [bookingDetails] = await connection.execute(sqlGetBookingDetails, [bookingId]);
            if (bookingDetails.length > 0) {
                const { room_id, start_time, end_time } = bookingDetails[0];
                let slotColumn;

                // กำหนด slotColumn ตามช่วงเวลา start_time และ end_time
                if (start_time === '08:00:00' && end_time === '10:00:00') {
                    slotColumn = 'first_slot';
                } else if (start_time === '10:00:00' && end_time === '12:00:00') {
                    slotColumn = 'second_slot';
                } else if (start_time === '13:00:00' && end_time === '15:00:00') {
                    slotColumn = 'third_slot';
                } else if (start_time === '15:00:00' && end_time === '17:00:00') {
                    slotColumn = 'fourth_slot';
                }

                if (slotColumn) {
                    const sqlUpdateRoomSlot = `
                      UPDATE rooms
                      SET ${slotColumn} = 'free'
                      WHERE room_id = ?
                    `;
                    await connection.execute(sqlUpdateRoomSlot, [room_id]);
                }

                res.json({ message: 'Booking and room slot updated successfully' });
            } else {
                res.status(404).json({ message: 'Booking details not found' });
            }
        } else {
            res.status(404).json({ message: 'Booking not found' });
        }
    } catch (error) {
        console.error('Error updating booking:', error.message);
        res.status(500).json({ message: 'Server error', error: error.message });
    }
});

// Register
app.post('/register', async (req, res) => {
    const { email, password, first_name, last_name, phone_number } = req.body;
    try {
        const [existingUsers] = await connection.execute('SELECT * FROM users WHERE email = ?', [email]);
        if (existingUsers.length > 0) {
            return res.status(400).json({ message: 'Email already exists' });
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        await connection.execute('INSERT INTO users (email, password, first_name, last_name, phone_number) VALUES (?, ?, ?, ?, ?)',
            [email, hashedPassword, first_name, last_name, phone_number]);

        res.status(201).json({ message: 'User registered successfully' });
    } catch (error) {
        handleError(res, error);
    }
});

// Check request status
app.get('/checkReq/:user_id', async (req, res) => {
    const userId = req.params.user_id; // Get user_id from the request parameters

    try {
        const [rows] = await connection.execute(`
            SELECT bookings.*, 
                   CONCAT(DATE_FORMAT(bookings.start_time, '%H:%i'), ' - ', DATE_FORMAT(bookings.end_time, '%H:%i')) AS time, 
                   rooms.room_name AS label 
            FROM bookings 
            LEFT JOIN rooms ON bookings.room_id = rooms.room_id
            WHERE bookings.user_id = ?  -- Filter by user_id
        `, [userId]);  // Pass userId as a parameter to prevent SQL injection

        res.status(200).json(rows); // Send only the filtered rows
    } catch (error) {
        handleError(res, error); // Handle any errors
    }
});



// Request history staff
const getRequestHistoryStaff = async (req, res) => {
    try {
        const [results] = await connection.execute(`
            SELECT 
                u.first_name AS user_first_name, 
                u.last_name AS user_last_name, 
                r.room_name AS room_name, 
                b.start_time, 
                b.end_time, 
                TIME_FORMAT(b.start_time, '%H:%i') AS start_time,  
                TIME_FORMAT(b.end_time, '%H:%i') AS end_time,
                b.date, 
                DATE_FORMAT(b.date, '%d/%m/%Y') AS date,
                a.first_name AS approver_first_name, 
                a.last_name AS approver_last_name, 
                CASE 
                    WHEN b.status = 'rejected' THEN 'Disapprove' 
                    WHEN b.status = 'approved' THEN 'Approve'
                    ELSE b.status 
                END AS status 
            FROM 
                bookings b
            LEFT JOIN 
                users u ON b.user_id = u.user_id
            LEFT JOIN 
                users a ON b.approver_id = a.user_id
            LEFT JOIN 
                rooms r ON b.room_id = r.room_id
            WHERE 
                b.status != 'pending'
        `);
        res.status(200).json(results);
    } catch (error) {
        handleError(res, error);
    }
};
app.get('/requestHistoryStaff', getRequestHistoryStaff);

// Request history lecturer
const getRequestHistoryLecturer = async (req, res) => {
    const userId = req.params.user_id; // รับ user_id จากพารามิเตอร์ใน URL
    try {
        const [results] = await connection.execute(`
            SELECT 
                u.first_name AS user_first_name, 
                u.last_name AS user_last_name, 
                r.room_name AS room_name, 
                b.start_time, 
                b.end_time, 
                TIME_FORMAT(b.start_time, '%H:%i') AS start_time,  
                TIME_FORMAT(b.end_time, '%H:%i') AS end_time,
                b.date, 
                DATE_FORMAT(b.date, '%d/%m/%Y') AS date,
                a.first_name AS approver_first_name, 
                a.last_name AS approver_last_name, 
                CASE 
                    WHEN b.status = 'rejected' THEN 'Disapprove' 
                    WHEN b.status = 'approved' THEN 'Approve'
                    ELSE b.status 
                END AS status 
            FROM 
                bookings b
            LEFT JOIN 
                users u ON b.user_id = u.user_id
            LEFT JOIN 
                users a ON b.approver_id = a.user_id
            LEFT JOIN 
                rooms r ON b.room_id = r.room_id
            WHERE 
                b.status != 'pending' AND b.approver_id = ?
        `, [userId]);
        res.status(200).json(results);
    } catch (error) {
        handleError(res, error);
    }
};
app.get('/requestHistoryLecturer/:user_id', getRequestHistoryLecturer);

// Dashboard
app.get('/dashBoard', async (req, res) => {
    try {
        const [results] = await connection.execute(`
            SELECT 
                SUM(CASE WHEN room_status = 'enabled' AND first_slot = 'free' THEN 1 ELSE 0 END) +
                SUM(CASE WHEN room_status = 'enabled' AND second_slot = 'free' THEN 1 ELSE 0 END) +
                SUM(CASE WHEN room_status = 'enabled' AND third_slot = 'free' THEN 1 ELSE 0 END) +
                SUM(CASE WHEN room_status = 'enabled' AND fourth_slot = 'free' THEN 1 ELSE 0 END) AS available,
                
                SUM(CASE WHEN room_status = 'enabled' AND first_slot = 'reserved' THEN 1 ELSE 0 END) +
                SUM(CASE WHEN room_status = 'enabled' AND second_slot = 'reserved' THEN 1 ELSE 0 END) +
                SUM(CASE WHEN room_status = 'enabled' AND third_slot = 'reserved' THEN 1 ELSE 0 END) +
                SUM(CASE WHEN room_status = 'enabled' AND fourth_slot = 'reserved' THEN 1 ELSE 0 END) AS reserved,
                
                SUM(CASE WHEN room_status = 'enabled' AND first_slot = 'pending' THEN 1 ELSE 0 END) +
                SUM(CASE WHEN room_status = 'enabled' AND second_slot = 'pending' THEN 1 ELSE 0 END) +
                SUM(CASE WHEN room_status = 'enabled' AND third_slot = 'pending' THEN 1 ELSE 0 END) +
                SUM(CASE WHEN room_status = 'enabled' AND fourth_slot = 'pending' THEN 1 ELSE 0 END) AS pending,

                SUM(CASE WHEN room_status = 'disabled' THEN 1 ELSE 0 END) AS disabled
            FROM rooms;
        `);
        res.json(results[0]);
    } catch (error) {
        handleError(res, error);
    }
});

// Start the server
app.listen(port, () => {
    console.log(`Server is running at port ${port}`);
});