-- Database setup for Stories feature
-- Run these SQL commands in your Supabase SQL editor

-- Create stories table
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

-- Create story_reactions table
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

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_stories_user_id ON stories(user_id);
CREATE INDEX IF NOT EXISTS idx_stories_created_at ON stories(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_story_reactions_story_id ON story_reactions(story_id);
CREATE INDEX IF NOT EXISTS idx_story_reactions_user_id ON story_reactions(user_id);

-- Enable Row Level Security (RLS)
ALTER TABLE stories ENABLE ROW LEVEL SECURITY;
ALTER TABLE story_reactions ENABLE ROW LEVEL SECURITY;

-- Create policies for stories table
CREATE POLICY "Users can view all stories" ON stories
  FOR SELECT USING (true);

CREATE POLICY "Users can create their own stories" ON stories
  FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can update their own stories" ON stories
  FOR UPDATE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can delete their own stories" ON stories
  FOR DELETE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

-- Create policies for story_reactions table
CREATE POLICY "Users can view all story reactions" ON story_reactions
  FOR SELECT USING (true);

CREATE POLICY "Users can create reactions" ON story_reactions
  FOR INSERT WITH CHECK (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can update their own reactions" ON story_reactions
  FOR UPDATE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

CREATE POLICY "Users can delete their own reactions" ON story_reactions
  FOR DELETE USING (auth.uid()::text = user_id OR user_id LIKE 'user_%');

-- Create function to update updated_at timestamp
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

-- Create triggers to automatically update updated_at
CREATE TRIGGER update_stories_updated_at BEFORE UPDATE ON stories
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_story_reactions_updated_at BEFORE UPDATE ON story_reactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
