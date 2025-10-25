import { useState } from 'react';
import { Button } from '@/components/ui/button';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Card } from '@/components/ui/card';
import { useToast } from '@/hooks/use-toast';
import { Search, MapPin } from 'lucide-react';

const SearchTab = () => {
  const [keyword, setKeyword] = useState('');
  const [city, setCity] = useState('');
  const [province, setProvince] = useState('');
  const [district, setDistrict] = useState('');
  const [loading, setLoading] = useState(false);
  const { toast } = useToast();

  const handleSearch = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    
    try {
      // Placeholder - implement Google Maps scraping logic here
      toast({
        title: 'Pencarian dimulai',
        description: `Mencari "${keyword}" di ${city}, ${province}`,
      });
      
      // TODO: Implement actual search logic
      setTimeout(() => {
        setLoading(false);
        toast({
          title: 'Pencarian selesai',
          description: 'Hasil tersimpan di database',
        });
      }, 2000);
    } catch (error: any) {
      toast({
        variant: 'destructive',
        title: 'Gagal melakukan pencarian',
        description: error.message,
      });
      setLoading(false);
    }
  };

  return (
    <div className="space-y-6">
      <div>
        <h2 className="text-2xl font-bold mb-2">Cari Bisnis</h2>
        <p className="text-muted-foreground">
          Masukkan kata kunci dan lokasi untuk mencari bisnis di Google Maps
        </p>
      </div>

      <form onSubmit={handleSearch} className="space-y-4">
        <div className="grid gap-4 md:grid-cols-2">
          <div className="space-y-2">
            <Label htmlFor="keyword">Kata Kunci *</Label>
            <Input
              id="keyword"
              placeholder="contoh: restoran, hotel, cafe"
              value={keyword}
              onChange={(e) => setKeyword(e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="city">Kota *</Label>
            <Input
              id="city"
              placeholder="contoh: Jakarta"
              value={city}
              onChange={(e) => setCity(e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="province">Provinsi *</Label>
            <Input
              id="province"
              placeholder="contoh: DKI Jakarta"
              value={province}
              onChange={(e) => setProvince(e.target.value)}
              required
            />
          </div>

          <div className="space-y-2">
            <Label htmlFor="district">Kecamatan (opsional)</Label>
            <Input
              id="district"
              placeholder="contoh: Menteng"
              value={district}
              onChange={(e) => setDistrict(e.target.value)}
            />
          </div>
        </div>

        <Button type="submit" className="w-full" disabled={loading}>
          <Search className="h-4 w-4 mr-2" />
          {loading ? 'Mencari...' : 'Mulai Pencarian'}
        </Button>
      </form>

      <Card className="p-4 bg-blue-50 border-blue-200">
        <div className="flex items-start gap-3">
          <MapPin className="h-5 w-5 text-blue-600 mt-0.5" />
          <div>
            <h3 className="font-semibold text-blue-900">Informasi</h3>
            <p className="text-sm text-blue-700 mt-1">
              Hasil pencarian akan disimpan dan dapat diakses di tab Favorit, Folder, atau Catatan
            </p>
          </div>
        </div>
      </Card>
    </div>
  );
};

export default SearchTab;
