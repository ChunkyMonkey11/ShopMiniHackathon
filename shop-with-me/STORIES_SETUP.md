# Stories Feature Setup Guide

## Overview
The Stories feature allows users to share products from their saved items and get voting/reactions from friends. Users can create story posts asking for opinions on products they're considering buying.

## Features
- **Create Stories**: Share products from saved items with optional captions
- **Vote/React**: Friends can react with Yes/No/Maybe/Love/Fire emojis
- **Browse Stories**: View all friends' stories in a feed
- **Real-time Updates**: See reactions as they happen

## Database Setup

### 1. Run the SQL Setup
Copy and paste the contents of `database-setup.sql` into your Supabase SQL editor and run it. This will create:

- `stories` table - stores story posts
- `story_reactions` table - stores user reactions to stories
- Proper indexes for performance
- Row Level Security policies
- Automatic timestamp updates

### 2. Verify Tables
After running the SQL, you should see two new tables in your Supabase dashboard:
- `stories`
- `story_reactions`

## How to Use

### Creating a Story
1. Click the "Stories" bubble on the home screen
2. Click "Create Story" button
3. Choose a product from your saved items
4. Add an optional caption explaining why you're considering the product
5. Click "Post Story"

### Reacting to Stories
1. Browse stories in the Stories feed
2. Click on any story to view details
3. Choose your reaction:
   - 👍 Yes! - You should get it
   - 👎 No - Don't buy it
   - 🤔 Maybe - On the fence
   - ❤️ Love it! - Great choice
   - 🔥 Fire! - Amazing product

### Viewing Reactions
- See all reactions on each story
- View who reacted and what they said
- Your own reaction is highlighted

## Technical Implementation

### Components
- `Stories.tsx` - Main stories component with three views:
  - `browse` - View all stories
  - `create` - Create new story
  - `view` - View individual story with reactions

### Database Schema
```sql
-- Stories table
stories (
  id UUID PRIMARY KEY,
  user_id TEXT,
  user_handle TEXT,
  user_display_name TEXT,
  product_data JSONB,
  caption TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)

-- Story reactions table
story_reactions (
  id UUID PRIMARY KEY,
  story_id UUID REFERENCES stories(id),
  user_id TEXT,
  user_handle TEXT,
  user_display_name TEXT,
  reaction_type TEXT CHECK (IN ('yes', 'no', 'maybe', 'love', 'fire')),
  comment TEXT,
  created_at TIMESTAMP,
  updated_at TIMESTAMP
)
```

### Integration Points
- Uses `useSavedProducts` hook from Shopify Mini to get saved products
- Integrates with existing user profile system
- Follows same design patterns as other components
- Uses Supabase for real-time data storage

## Customization

### Adding New Reaction Types
To add new reaction types:
1. Update the `reaction_type` CHECK constraint in the database
2. Add the new reaction to the `StoryReaction` type
3. Update the reaction UI components

### Styling
The component uses Tailwind CSS classes and follows the existing design system. You can customize:
- Colors and themes
- Layout and spacing
- Animation effects
- Typography

## Troubleshooting

### Common Issues
1. **Stories not loading**: Check database connection and RLS policies
2. **Can't create stories**: Verify user profile exists
3. **Reactions not saving**: Check database permissions
4. **Saved products not showing**: Ensure `useSavedProducts` hook is working

### Debug Mode
Enable console logging by checking the browser console for:
- Database query results
- User authentication status
- Product loading status
- Error messages

## Future Enhancements
- Add comment functionality to reactions
- Implement story expiration (24-hour stories)
- Add story sharing capabilities
- Create story analytics and insights
- Add product purchase tracking
