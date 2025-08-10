-- Complete Database Setup for Shop Mini App
-- Run these SQL commands in your Supabase SQL editor

-- ========================================
-- EXISTING TABLES (Already in use)
-- ========================================

-- User profiles table (existing)
CREATE TABLE IF NOT EXISTS user_profiles (
  user_id TEXT PRIMARY KEY,
  handle TEXT UNIQUE NOT NULL,
  display_name TEXT NOT NULL,
  profile_pic TEXT,
  gender_affinity TEXT,
  category_affinities TEXT[],
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_active TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- User feed items table (existing)
CREATE TABLE IF NOT EXISTS user_feed_items (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL REFERENCES user_profiles(user_id) ON DELETE CASCADE,
  product_id TEXT NOT NULL,
  product_data JSONB NOT NULL,
  source TEXT NOT NULL CHECK (source IN ('recommended_products', 'recommended_shops', 'product_lists', 'followed_shops', 'saved_products')),
  added_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- NEW TABLES (Stories Feature)
-- ========================================

-- Stories table (new)
CREATE TABLE IF NOT EXISTS stories (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id TEXT NOT NULL,
  user_handle TEXT NOT NULL,
  user_display_name TEXT NOT NULL,
  product_data JSONB NOT NULL,
  caption TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Story reactions table (new)
CREATE TABLE IF NOT EXISTS story_reactions (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  story_id UUID NOT NULL REFERENCES stories(id) ON DELETE CASCADE,
  user_id TEXT NOT NULL,
  user_handle TEXT NOT NULL,
  user_display_name TEXT NOT NULL,
  reaction_type TEXT NOT NULL CHECK (reaction_type IN ('yes', 'no', 'maybe', 'love', 'fire')),
  comment TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- INDEXES FOR PERFORMANCE
-- ========================================

-- Existing table indexes
CREATE INDEX IF NOT EXISTS idx_user_feed_items_user_id ON user_feed_items(user_id);
CREATE INDEX IF NOT EXISTS idx_user_feed_items_source ON user_feed_items(source);
CREATE INDEX IF NOT EXISTS idx_user_feed_items_added_at ON user_feed_items(added_at DESC);
CREATE INDEX IF NOT EXISTS idx_user_profiles_handle ON user_profiles(handle);
CREATE INDEX IF NOT EXISTS idx_user_profiles_last_active ON user_profiles(last_active DESC);

-- New table indexes
CREATE INDEX IF NOT EXISTS idx_stories_user_id ON stories(user_id);
CREATE INDEX IF NOT EXISTS idx_stories_created_at ON stories(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_story_reactions_story_id ON story_reactions(story_id);
CREATE INDEX IF NOT EXISTS idx_story_reactions_user_id ON story_reactions(user_id);

-- ========================================
-- ROW LEVEL SECURITY (RLS)
-- ========================================

-- Enable RLS on all tables
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_feed_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE story_reactions ENABLE ROW LEVEL SECURITY;

-- User profiles policies
CREATE POLICY "Users can view all profiles" ON user_profiles
  FOR SELECT USING (true);

CREATE POLICY "Users can create their own profile" ON user_profiles
  FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can update their own profile" ON user_profiles
  FOR UPDATE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

-- User feed items policies
CREATE POLICY "Users can view all feed items" ON user_feed_items
  FOR SELECT USING (true);

CREATE POLICY "Users can create their own feed items" ON user_feed_items
  FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can update their own feed items" ON user_feed_items
  FOR UPDATE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can delete their own feed items" ON user_feed_items
  FOR DELETE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

-- Stories policies
CREATE POLICY "Users can view all stories" ON stories
  FOR SELECT USING (true);

CREATE POLICY "Users can create their own stories" ON stories
  FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can update their own stories" ON stories
  FOR UPDATE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can delete their own stories" ON stories
  FOR DELETE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

-- Story reactions policies
CREATE POLICY "Users can view all story reactions" ON story_reactions
  FOR SELECT USING (true);

CREATE POLICY "Users can create reactions" ON story_reactions
  FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can update their own reactions" ON story_reactions
  FOR UPDATE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can delete their own reactions" ON story_reactions
  FOR DELETE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

-- ========================================
-- TRIGGERS AND FUNCTIONS
-- ========================================

-- Function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Triggers for updated_at columns
CREATE TRIGGER update_stories_updated_at BEFORE UPDATE ON stories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_story_reactions_updated_at BEFORE UPDATE ON story_reactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ========================================
-- SAMPLE DATA (Optional)
-- ========================================

-- Insert sample user profiles (uncomment if you want sample data)
/*
INSERT INTO user_profiles (user_id, handle, display_name, created_at, last_active) VALUES
('user_john_doe', 'johndoe', 'John Doe', NOW(), NOW()),
('user_jane_smith', 'janesmith', 'Jane Smith', NOW(), NOW()),
('user_bob_wilson', 'bobwilson', 'Bob Wilson', NOW(), NOW())
ON CONFLICT (user_id) DO NOTHING;
*/

-- ========================================
-- VERIFICATION QUERIES
-- ========================================

-- Check if tables were created successfully
SELECT 
  table_name,
  CASE 
    WHEN table_name IN ('user_profiles', 'user_feed_items', 'stories', 'story_reactions') 
    THEN '✅ Created' 
    ELSE '❌ Missing' 
  END as status
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('user_profiles', 'user_feed_items', 'stories', 'story_reactions')
ORDER BY table_name;

-- Check RLS policies
SELECT 
  schemaname,
  tablename,
  policyname,
  permissive,
  roles,
  cmd,
  qual
FROM pg_policies 
WHERE schemaname = 'public' 
  AND tablename IN ('user_profiles', 'user_feed_items', 'stories', 'story_reactions')
ORDER BY tablename, policyname;
