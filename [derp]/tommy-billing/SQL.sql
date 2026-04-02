-- ═══════════════════════════════════════════════════════════
-- TOMMY BILLING - DATABASE SCHEMA
-- ═══════════════════════════════════════════════════════════

CREATE TABLE IF NOT EXISTS `billing_history` (
    `id` INT AUTO_INCREMENT PRIMARY KEY,
    `bill_id` VARCHAR(20) NOT NULL UNIQUE,
    
    -- Nhân viên (người viết bill)
    `biller_citizenid` VARCHAR(50) NOT NULL,
    `biller_name` VARCHAR(100) NOT NULL,
    `biller_job` VARCHAR(50) NOT NULL,
    `biller_job_label` VARCHAR(100) NOT NULL,
    
    -- Khách hàng (người nhận bill)
    `target_citizenid` VARCHAR(50) NOT NULL,
    `target_name` VARCHAR(100) NOT NULL,
    
    -- Chi tiết bill
    `reason` VARCHAR(255) NOT NULL,
    `amount` INT NOT NULL,
    `commission` INT DEFAULT 0,
    `society_amount` INT NOT NULL,
    `payment_method` ENUM('cash', 'bank') NOT NULL,
    
    -- Trạng thái: pending, paid, rejected, cancelled, auto_paid
    `status` ENUM('pending', 'paid', 'rejected', 'cancelled', 'auto_paid') DEFAULT 'pending',
    
    -- Lý do hủy (nếu cancelled)
    `cancel_reason` VARCHAR(255) NULL,
    
    -- Thời gian
    `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    `updated_at` TIMESTAMP NULL,
    `due_date` TIMESTAMP NULL,  -- Ngày tự động trừ tiền (created_at + 7 ngày)
    
    -- Index để query nhanh
    INDEX `idx_biller` (`biller_citizenid`),
    INDEX `idx_target` (`target_citizenid`),
    INDEX `idx_job` (`biller_job`),
    INDEX `idx_status` (`status`),
    INDEX `idx_due_date` (`due_date`),
    INDEX `idx_created` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;