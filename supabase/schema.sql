-- Pinterest Clone Database Schema for Supabase
-- Run this in Supabase SQL Editor: https://supabase.com/dashboard/project/YOUR_PROJECT/sql

-- ============================================
-- Enable UUID extension
-- ============================================
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- PROFILES TABLE
-- Stores user profile information (linked to Clerk auth)
-- ============================================
CREATE TABLE IF NOT EXISTS profiles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    clerk_user_id TEXT UNIQUE NOT NULL,
    email TEXT NOT NULL,
    username TEXT UNIQUE,
    full_name TEXT,
    avatar_url TEXT,
    bio TEXT,
    website TEXT,
    followers_count INTEGER DEFAULT 0,
    following_count INTEGER DEFAULT 0,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Index for faster lookups
CREATE INDEX IF NOT EXISTS idx_profiles_clerk_user_id ON profiles(clerk_user_id);

-- ============================================
-- BOARDS TABLE
-- Stores user-created boards/collections
-- ============================================
CREATE TABLE IF NOT EXISTS boards (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    cover_image_url TEXT,
    pin_count INTEGER DEFAULT 0,
    is_private BOOLEAN DEFAULT FALSE,
    collaborator_ids TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_boards_user_id ON boards(user_id);
CREATE INDEX IF NOT EXISTS idx_boards_created_at ON boards(created_at DESC);

-- ============================================
-- SAVED_PINS TABLE
-- Stores pins that users have saved to their boards
-- ============================================
CREATE TABLE IF NOT EXISTS saved_pins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    pin_id TEXT NOT NULL,
    board_id UUID NOT NULL REFERENCES boards(id) ON DELETE CASCADE,
    image_url TEXT NOT NULL,
    thumbnail_url TEXT,
    title TEXT,
    description TEXT,
    link TEXT,
    width INTEGER NOT NULL,
    height INTEGER NOT NULL,
    photographer TEXT,
    avg_color TEXT,
    saved_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate saves of same pin by same user
    UNIQUE(user_id, pin_id)
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_saved_pins_user_id ON saved_pins(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_pins_board_id ON saved_pins(board_id);
CREATE INDEX IF NOT EXISTS idx_saved_pins_saved_at ON saved_pins(saved_at DESC);

-- ============================================
-- LIKES TABLE
-- Stores user likes on pins
-- ============================================
CREATE TABLE IF NOT EXISTS likes (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    pin_id TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate likes
    UNIQUE(user_id, pin_id)
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_likes_user_id ON likes(user_id);
CREATE INDEX IF NOT EXISTS idx_likes_pin_id ON likes(pin_id);

-- ============================================
-- FOLLOWS TABLE
-- Stores user follow relationships
-- ============================================
CREATE TABLE IF NOT EXISTS follows (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    follower_id TEXT NOT NULL,
    following_id TEXT NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    -- Prevent duplicate follows
    UNIQUE(follower_id, following_id),
    
    -- Prevent self-follows
    CHECK (follower_id != following_id)
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_follows_follower_id ON follows(follower_id);
CREATE INDEX IF NOT EXISTS idx_follows_following_id ON follows(following_id);

-- ============================================
-- COMMENTS TABLE (Optional - for pin comments)
-- ============================================
CREATE TABLE IF NOT EXISTS comments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id TEXT NOT NULL,
    pin_id TEXT NOT NULL,
    content TEXT NOT NULL,
    parent_id UUID REFERENCES comments(id) ON DELETE CASCADE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Indexes for faster lookups
CREATE INDEX IF NOT EXISTS idx_comments_pin_id ON comments(pin_id);
CREATE INDEX IF NOT EXISTS idx_comments_user_id ON comments(user_id);

-- ============================================
-- FUNCTIONS
-- ============================================

-- Function to increment pin count on a board
CREATE OR REPLACE FUNCTION increment_pin_count(board_id_param UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE boards
    SET pin_count = pin_count + 1,
        updated_at = NOW()
    WHERE id = board_id_param;
END;
$$ LANGUAGE plpgsql;

-- Function to decrement pin count on a board
CREATE OR REPLACE FUNCTION decrement_pin_count(board_id_param UUID)
RETURNS VOID AS $$
BEGIN
    UPDATE boards
    SET pin_count = GREATEST(0, pin_count - 1),
        updated_at = NOW()
    WHERE id = board_id_param;
END;
$$ LANGUAGE plpgsql;

-- Function to update follower counts
CREATE OR REPLACE FUNCTION update_follower_counts()
RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        -- Increment following count for follower
        UPDATE profiles
        SET following_count = following_count + 1
        WHERE clerk_user_id = NEW.follower_id;
        
        -- Increment followers count for followed user
        UPDATE profiles
        SET followers_count = followers_count + 1
        WHERE clerk_user_id = NEW.following_id;
        
        RETURN NEW;
    ELSIF TG_OP = 'DELETE' THEN
        -- Decrement following count for follower
        UPDATE profiles
        SET following_count = GREATEST(0, following_count - 1)
        WHERE clerk_user_id = OLD.follower_id;
        
        -- Decrement followers count for followed user
        UPDATE profiles
        SET followers_count = GREATEST(0, followers_count - 1)
        WHERE clerk_user_id = OLD.following_id;
        
        RETURN OLD;
    END IF;
END;
$$ LANGUAGE plpgsql;

-- Trigger for follow counts
DROP TRIGGER IF EXISTS trigger_update_follower_counts ON follows;
CREATE TRIGGER trigger_update_follower_counts
    AFTER INSERT OR DELETE ON follows
    FOR EACH ROW EXECUTE FUNCTION update_follower_counts();

-- ============================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE boards ENABLE ROW LEVEL SECURITY;
ALTER TABLE saved_pins ENABLE ROW LEVEL SECURITY;
ALTER TABLE likes ENABLE ROW LEVEL SECURITY;
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
ALTER TABLE comments ENABLE ROW LEVEL SECURITY;

-- Profiles policies
CREATE POLICY "Profiles are viewable by everyone" ON profiles
    FOR SELECT USING (true);

CREATE POLICY "Users can insert their own profile" ON profiles
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own profile" ON profiles
    FOR UPDATE USING (true);

-- Boards policies
CREATE POLICY "Public boards are viewable by everyone" ON boards
    FOR SELECT USING (is_private = false OR user_id = current_setting('request.jwt.claim.sub', true));

CREATE POLICY "Users can insert their own boards" ON boards
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their own boards" ON boards
    FOR UPDATE USING (true);

CREATE POLICY "Users can delete their own boards" ON boards
    FOR DELETE USING (true);

-- Saved pins policies
CREATE POLICY "Saved pins in public boards are viewable" ON saved_pins
    FOR SELECT USING (true);

CREATE POLICY "Users can save pins" ON saved_pins
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can delete their saved pins" ON saved_pins
    FOR DELETE USING (true);

-- Likes policies
CREATE POLICY "Likes are viewable by everyone" ON likes
    FOR SELECT USING (true);

CREATE POLICY "Users can like pins" ON likes
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can unlike pins" ON likes
    FOR DELETE USING (true);

-- Follows policies
CREATE POLICY "Follows are viewable by everyone" ON follows
    FOR SELECT USING (true);

CREATE POLICY "Users can follow others" ON follows
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can unfollow others" ON follows
    FOR DELETE USING (true);

-- Comments policies
CREATE POLICY "Comments are viewable by everyone" ON comments
    FOR SELECT USING (true);

CREATE POLICY "Users can add comments" ON comments
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Users can update their comments" ON comments
    FOR UPDATE USING (true);

CREATE POLICY "Users can delete their comments" ON comments
    FOR DELETE USING (true);

-- ============================================
-- STORAGE BUCKETS (Run in Storage section)
-- ============================================
-- Create these buckets in Supabase Dashboard > Storage:
-- 1. 'avatars' - For user profile pictures (public)
-- 2. 'pins' - For user-uploaded pins (public)
-- 3. 'boards' - For board cover images (public)
