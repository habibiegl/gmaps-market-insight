-- Create profiles table for user data
CREATE TABLE public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email text,
  full_name text,
  avatar_url text,
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Trigger to create profile on signup
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  INSERT INTO public.profiles (id, email, full_name)
  VALUES (
    new.id,
    new.email,
    new.raw_user_meta_data->>'full_name'
  );
  RETURN new;
END;
$$;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Add user_id columns to all tables
ALTER TABLE public.search_history ADD COLUMN user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE public.scraping_results ADD COLUMN user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE public.favorites ADD COLUMN user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE public.business_notes ADD COLUMN user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE public.folders ADD COLUMN user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;
ALTER TABLE public.tags ADD COLUMN user_id uuid REFERENCES public.profiles(id) ON DELETE CASCADE;

-- Make user_id NOT NULL for new records (existing NULL records allowed for migration)
-- We'll set defaults for existing records
UPDATE public.search_history SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
UPDATE public.scraping_results SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
UPDATE public.favorites SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
UPDATE public.business_notes SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
UPDATE public.folders SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;
UPDATE public.tags SET user_id = (SELECT id FROM auth.users LIMIT 1) WHERE user_id IS NULL;

-- Drop old public policies
DROP POLICY IF EXISTS "Allow public read access on search_history" ON public.search_history;
DROP POLICY IF EXISTS "Allow public insert access on search_history" ON public.search_history;
DROP POLICY IF EXISTS "Allow public delete access on search_history" ON public.search_history;

DROP POLICY IF EXISTS "Allow public read access on scraping_results" ON public.scraping_results;
DROP POLICY IF EXISTS "Allow public insert access on scraping_results" ON public.scraping_results;
DROP POLICY IF EXISTS "Allow public delete access on scraping_results" ON public.scraping_results;

DROP POLICY IF EXISTS "Allow public read access on favorites" ON public.favorites;
DROP POLICY IF EXISTS "Allow public insert access on favorites" ON public.favorites;
DROP POLICY IF EXISTS "Allow public update access on favorites" ON public.favorites;
DROP POLICY IF EXISTS "Allow public delete access on favorites" ON public.favorites;

DROP POLICY IF EXISTS "Allow public read access on business_notes" ON public.business_notes;
DROP POLICY IF EXISTS "Allow public insert access on business_notes" ON public.business_notes;
DROP POLICY IF EXISTS "Allow public update access on business_notes" ON public.business_notes;
DROP POLICY IF EXISTS "Allow public delete access on business_notes" ON public.business_notes;

DROP POLICY IF EXISTS "Allow public read access on folders" ON public.folders;
DROP POLICY IF EXISTS "Allow public insert access on folders" ON public.folders;
DROP POLICY IF EXISTS "Allow public update access on folders" ON public.folders;
DROP POLICY IF EXISTS "Allow public delete access on folders" ON public.folders;

DROP POLICY IF EXISTS "Allow public read access on folder_items" ON public.folder_items;
DROP POLICY IF EXISTS "Allow public insert access on folder_items" ON public.folder_items;
DROP POLICY IF EXISTS "Allow public delete access on folder_items" ON public.folder_items;

DROP POLICY IF EXISTS "Allow public read access on tags" ON public.tags;
DROP POLICY IF EXISTS "Allow public insert access on tags" ON public.tags;
DROP POLICY IF EXISTS "Allow public delete access on tags" ON public.tags;

DROP POLICY IF EXISTS "Allow public read access on result_tags" ON public.result_tags;
DROP POLICY IF EXISTS "Allow public insert access on result_tags" ON public.result_tags;
DROP POLICY IF EXISTS "Allow public delete access on result_tags" ON public.result_tags;

-- Create user-scoped RLS policies
-- Profiles
CREATE POLICY "Users can view own profile" ON public.profiles FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own profile" ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- Search history
CREATE POLICY "Users can view own search history" ON public.search_history FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own search history" ON public.search_history FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own search history" ON public.search_history FOR DELETE USING (auth.uid() = user_id);

-- Scraping results
CREATE POLICY "Users can view own scraping results" ON public.scraping_results FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own scraping results" ON public.scraping_results FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own scraping results" ON public.scraping_results FOR DELETE USING (auth.uid() = user_id);

-- Favorites
CREATE POLICY "Users can view own favorites" ON public.favorites FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own favorites" ON public.favorites FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own favorites" ON public.favorites FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own favorites" ON public.favorites FOR DELETE USING (auth.uid() = user_id);

-- Business notes
CREATE POLICY "Users can view own business notes" ON public.business_notes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own business notes" ON public.business_notes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own business notes" ON public.business_notes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own business notes" ON public.business_notes FOR DELETE USING (auth.uid() = user_id);

-- Folders
CREATE POLICY "Users can view own folders" ON public.folders FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own folders" ON public.folders FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own folders" ON public.folders FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own folders" ON public.folders FOR DELETE USING (auth.uid() = user_id);

-- Folder items (linked to folders)
CREATE POLICY "Users can view own folder items" ON public.folder_items FOR SELECT 
  USING (EXISTS (SELECT 1 FROM public.folders WHERE folders.id = folder_items.folder_id AND folders.user_id = auth.uid()));
CREATE POLICY "Users can insert own folder items" ON public.folder_items FOR INSERT 
  WITH CHECK (EXISTS (SELECT 1 FROM public.folders WHERE folders.id = folder_items.folder_id AND folders.user_id = auth.uid()));
CREATE POLICY "Users can delete own folder items" ON public.folder_items FOR DELETE 
  USING (EXISTS (SELECT 1 FROM public.folders WHERE folders.id = folder_items.folder_id AND folders.user_id = auth.uid()));

-- Tags
CREATE POLICY "Users can view own tags" ON public.tags FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can insert own tags" ON public.tags FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can delete own tags" ON public.tags FOR DELETE USING (auth.uid() = user_id);

-- Result tags (linked to tags)
CREATE POLICY "Users can view own result tags" ON public.result_tags FOR SELECT 
  USING (EXISTS (SELECT 1 FROM public.tags WHERE tags.id = result_tags.tag_id AND tags.user_id = auth.uid()));
CREATE POLICY "Users can insert own result tags" ON public.result_tags FOR INSERT 
  WITH CHECK (EXISTS (SELECT 1 FROM public.tags WHERE tags.id = result_tags.tag_id AND tags.user_id = auth.uid()));
CREATE POLICY "Users can delete own result tags" ON public.result_tags FOR DELETE 
  USING (EXISTS (SELECT 1 FROM public.tags WHERE tags.id = result_tags.tag_id AND tags.user_id = auth.uid()));

-- Add indexes for performance
CREATE INDEX IF NOT EXISTS idx_search_history_user_id ON public.search_history(user_id);
CREATE INDEX IF NOT EXISTS idx_scraping_results_user_id ON public.scraping_results(user_id);
CREATE INDEX IF NOT EXISTS idx_favorites_user_id ON public.favorites(user_id);
CREATE INDEX IF NOT EXISTS idx_business_notes_user_id ON public.business_notes(user_id);
CREATE INDEX IF NOT EXISTS idx_folders_user_id ON public.folders(user_id);
CREATE INDEX IF NOT EXISTS idx_tags_user_id ON public.tags(user_id);