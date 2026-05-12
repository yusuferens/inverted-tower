# Inverted Tower — Game Plan
**Engine:** Godot 4 | **Genre:** Dark Platformer / Metroidvania | **Setting:** Medieval / Occult / Cosmic Horror

---

## Oyun Özeti

Ortaçağ atmosferinde geçen karanlık bir platformer / metroidvania deneyimi.

Oyuncu, Babil Kulesi'ne ait olduğu düşünülen gizli bir kazı alanında çalışan isimsiz bir arkeologdur.
Kazı sırasında mühürlü bir kapı açılır ve oyuncu, yeraltına doğru inşa edilmiş "gerçek Babil" ile karşılaşır.

**Kule göğe değil aşağıya uzanmaktadır.**
Çünkü eski bir kült, Tanrı'nın gözetiminden kaçmak için kuleyi yeraltına inşa etmiştir.
Ancak ritüel başarısız olmuş, ve kült üyeleri "Sağırlar" adı verilen varlıklara dönüşmüştür.

---

## Ana Temalar

- Yasak bilgi
- Dil ve anlamın çöküşü
- Tanrı'nın gözetimi
- Sessizlik korkusu
- İnsan zihninin sınırları
- Kolektif bilinç
- Kimliğin kaybı
- Kozmik korku

---

## Atmosfer

Oyuncu giderek daha eski, daha bozulmuş ve daha gerçek dışı katmanlara iner.
Dünya ölmek üzere değil; çok uzun zaman önce ölmüştür.

**Oyunun hissi:**
Melankolik · Yalnız · Boğucu · Gizemli · Sessiz · Dini / Ritüelistik

---

## Hikâye Anlatım Tarzı

FromSoftware tarzı çevresel hikâye anlatımı hedeflenir.

Bilgiler şunlar üzerinden dolaylı aktarılır:
- NPC diyalogları
- Tablet yazıları
- Boss monologları
- Bölge tasarımı
- Item açıklamaları
- Mimari detaylar

**Oyuncuya hiçbir şey tamamen açıklanmaz.**

---

## Oyun Döngüsü

```
Yeni bölge keşfet
  → Antik semboller bul
  → Yeni dili çöz
  → Gizli yollar aç
  → Boss yen
  → Daha derine in
  → Gerçekliği sorgula
```

---

## Dil Mekaniği

Oyuncu ilerledikçe antik dili öğrenmeye başlar.

**Başlangıçta:**
- Yazılar anlamsız görünür
- NPC'ler bozuk konuşur

**Dil öğrenildikçe:**
- Yeni diyaloglar açılır
- Gizli kapılar aktif olur
- Dünya değişmeye başlar
- Yeni platformlar görünür

> Ancak bilgi aynı zamanda lanettir. Oyuncu da "duymaya" başlar.

---

## İlham Kaynakları

Dark Souls · Bloodborne · Hollow Knight · Blasphemous · INSIDE · Rain World
Lovecraft kozmik korkusu · Babil Kulesi miti

---

## Görsel Stil

**Önerilen stiller:**
- Karanlık pixel art
- Low poly gotik tasarım
- El çizimi atmosferik arka planlar

**Önemli olan:**
- Siluet okunabilirliği
- Işık kullanımı
- Derinlik hissi
- Büyük boşluklar

---

## Animasyon Yaklaşımı

Animasyonlar abartılı değil, ağır ve "eski" hissettirmeli.

- Boss hareketlerinde gecikme
- Ani sessizlikler
- İnsan dışı hareketler
- Yavaş dönüşler
- Ritüel hissi

---

## Ses Tasarımı

Ses oyunun temel yapı taşlarından biri olacak.

- Derin yankılar
- Bozuk dualar
- Ters çevrilmiş fısıltılar
- Metal sürtünmeleri
- Uzaktan gelen çan sesleri
- Uzun sessizlikler

> Bazı bölgelerde müzik tamamen kaldırılabilir.

---

## Boss Tasarımı

Bosslar klasik canavar değil, insanlığını kaybetmiş kutsal figürler gibi hissettirmeli.

| Boss | Konsept |
|------|---------|
| Sessiz Kâhin | — |
| Kulaksız Kral | — |
| Bin Dilli Anne | — |
| Gözetleyen | — |

---

## Dünya Yapısı (Bölgeler)

```
1. İşçilerin Mezarı      → Modern kazı ekibinin terk edilmiş kampı (tutorial)
2. Yankı Şehri           → Seslerin gecikmeli duyulduğu antik şehir
3. Kör Rahipler Manastırı → Tanrı'nın bakışından kaçmak için gözlerini çıkaran rahipler
4. Ters Saray            → Yerçekimi ve mimarinin bozulduğu bölge
5. Son Çan Kuyusu        → Mutlak sessizliğin bulunduğu son katman
```

Her bölgede:
- 2–3 ana oda + 1 gizli oda
- 1 lore collectible (tablet / yazıt)
- 1 mini-puzzle veya meydan okuma

---

## İlk Demo Hedefi (Vertical Slice)

**10–15 dakikalık oynanabilir demo.**

- [ ] Açılış sinematiği
- [ ] İlk bölge (İşçilerin Mezarı) — tam oynanabilir
- [ ] Basit combat sistemi
- [ ] 1 miniboss
- [ ] 2 NPC
- [ ] Dil çözme mekaniğinin ilk versiyonu

---

## Yol Haritası

### Aşama 0 — Temel Altyapı
**Hedef:** Test odasında oynanabilir karakter.

- [x] Godot projesi oluştur, klasör yapısını kur
- [x] `Player.tscn`: CharacterBody2D, hareket (yürü/koş/zıpla), saldırı, dodge
- [x] `GameState.gd` autoload: sağlık, akıl sağlığı, scroll listesi, checkpoint
- [x] `EventBus.gd` autoload: hasar, ölüm, lore, akıl sağlığı sinyalleri
- [x] Input map: move_left/right (A·D·←·→), jump (Space·W), attack (J·Z), dodge (K·X), interact (E·F)
- [x] Camera with screen-edge deadzone
- [x] Placeholder TileMap with one gray tile for collision testing
- [x] Death + respawn at last checkpoint'te yeniden doğma

---

### Aşama 1 — Sanat Temeli (PixelLab)
**Hedef:** Gerçek seviye inşasından önce tüm temel sprite'ları oluştur.

#### Protagonist — MEVCUT
- **ID:** `af0973e3-aaeb-45e0-b968-3467cd34e8c5`
- **Boyut:** 92×92px, 8 yön, view: low top-down
- **Animasyonlar:** Breathing_Idle (4f), Walking (6f), Attack-lunge (7f)
- **Yol:** `assets/sprites/characters/historian/`
- Sidescroller için: `south-east/` = sağa bak, `south-west/` = sola bak

Eksik animasyonlar (`animate_character` ile eklenecek): `hurt`, `death`, `run`, `jump`

#### Zombie Düşmanı — MEVCUT
- **ID:** `6d88c2ee-1e5d-4236-8502-e4779c1d34b3`
- **Boyut:** 120×120px, 8 yön, view: side
- **Animasyonlar:** Walking (6f), Attack-upward (5f)
- **Yol:** `assets/sprites/characters/zombie_enemy/`

Eksik animasyonlar: `hurt`, `death`, `idle`

#### Üretilecek Düşmanlar
| Düşman | Açıklama |
|--------|----------|
| Kültist Tarikat Üyesi | `"hooded cultist, ragged medieval robe, dagger"`, 64px |
| Kültist Okçu | `"hooded cultist, crossbow, dark medieval cloak"`, 64px |
| Ele Geçirilmiş Eser | `"ancient stone golem, cracked surface, glowing eyes"`, 80px |
| Tarikat Gardiyanı | `"armored medieval knight, inverted cross, large halberd"`, 80px |

#### Tilesetler — Stil zinciri ile
```
Bölge 1 — İşçilerin Mezarı     (crumbling medieval stone, weathered) seed:1001
Bölge 2 — Yankı Şehri          (ancient limestone, cobwebs, carved symbols) seed:1002
Bölge 3 — Kör Rahipler         (fractured sandstone, glowing amber cracks) seed:1003
Bölge 4 — Ters Saray           (ornate upside-down pillars, dark inverted moss) seed:1004
Bölge 5 — Son Çan Kuyusu       (polished black marble, ritual engravings) seed:1005
```

Her yeni tileset öncekinin `base_tile_id` değerini alır (stil tutarlılığı için).

#### Prop'lar
Duvar meşalesi · Sunak · Kitaplık · Lore parşömeni · Kaldıraç · Sandık · Kırık sütun · Kült sembolü · Sivri tuzak

---

### Aşama 2 — Bölge 1 & 2 (Demo)
**Hedef:** İlk iki bölge gerçek sanatla tam oynanabilir.

- [ ] Tilesetleri Godot TileSet kaynaklarına aktar
- [ ] `Zone1_IsciMezari.tscn` seviye düzeni
- [ ] `Zone2_YankiSehri.tscn` seviye düzeni
- [ ] Prop'ları StaticBody2D / Area2D node olarak yerleştir
- [ ] Kültist Tarikat Üyesi AI: devriye, aggro, saldırı, ölüm
- [ ] Kültist Okçu AI: dur, nişan al, mermi at, geri çekil
- [ ] `LoreScroll.tscn`: Area2D pickup → GameState'e kaydet, metin popup aç
- [ ] `SecretPassage.tscn`: interact ile kırılan ince duvar tile'ı
- [ ] Checkpoint sistemi
- [ ] HUD: sağlık barı, akıl sağlığı barı (Bölge 1–2'de gizli)
- [ ] Dil mekaniği — başlangıç versiyonu (anlamsız semboller → ilk çözüm)
- [ ] 2 NPC diyalogu
- [ ] 1 Miniboss (Sessiz Kâhin prototipi)

---

### Aşama 3 — Kalan Sanat (PixelLab)
- [ ] Bölge 3–5 tilesetleri (zincirlenmiş base_tile_id ile)
- [ ] PossessedRelic, Shade, CultWarden karakter + animasyonlar
- [ ] Boss objeleri: Kulaksız Kral, Bin Dilli Anne, Gözetleyen
- [ ] Kalan prop'lar
- [ ] `vary_object` ile Acolyte/Archer elite varyantları

---

### Aşama 4 — Bölge 3–5 & Çekirdek Sistemler
- [ ] Bölge 3 — Kör Rahipler Manastırı (yerçekimi bükülmesi platformları)
- [ ] Bölge 4 — Ters Saray (ters düzen, Shade düşmanları)
- [ ] Bölge 5 — Son Çan Kuyusu (yoğun düşman yerleşimi, mutlak sessizlik)
- [ ] Akıl sağlığı sistemi: Bölge 3–5'te yavaş azalma, ekran distorsiyon shader
- [ ] Boss dövüşleri: Kulaksız Kral, Bin Dilli Anne
- [ ] Final boss: Gözetleyen (çok aşamalı)
- [ ] Tam lore journal UI
- [ ] `SaveSystem.gd`: bölge ilerlemesi, sağlık, scroll'lar dosyaya kaydet

---

### Aşama 5 — Cilalama & Yayın
- [ ] Ana menü (yeni oyun / devam / çıkış)
- [ ] Duraklama menüsü
- [ ] Partikül efektleri: meşale dumanı, iniş tozu, çarpma kanı, geçersizlik parıltısı
- [ ] Boss saldırılarında ekran sarsıntısı
- [ ] Ölüm ekranı
- [ ] Ses: adım sesi, kılıç sesi, hasar sesi, ortam sesi
- [ ] Tam oynanış denge geçişi
- [ ] Final bug geçişi

---

## Oyuncu Sistemleri

| Sistem | Açıklama |
|--------|----------|
| Hareket | Yürü, koş, zıpla, çömel, duvar kaydır |
| Dövüş | Yakın dövüş (meşale/hançer), fırlatılabilir bıçaklar, dodge roll |
| Sağlık | 5 HP, bulunan sargı bezi ve bitkilerle yenilenir |
| Akıl Sağlığı | Bölge 3–5'te yavaş azalır; tam tükenme ekran distorsiyonu + shade spawn |
| Dil Sistemi | Antik semboller çözülerek yeni diyaloglar, kapılar, platformlar açılır |
| Lore Scrolls | Hikâyeyi genişleten koleksiyon; journal menüsünde takip edilir |
| Gizli Yollar | Gizli duvar geçitleri ekstra lore, HP yükseltme veya kısayol sağlar |

---

## Asset Takibi

### Karakterler
| İsim | ID | Boyut | Animasyonlar | Durum |
|------|----|-------|-------------|-------|
| Arkeolog (protagonist) | `af0973e3-aaeb-45e0-b968-3467cd34e8c5` | 92×92 | Idle (4f), Walk (6f), Attack (7f) | **tamam** |
| Zombie Düşmanı | `6d88c2ee-1e5d-4236-8502-e4779c1d34b3` | 120×120 | Walk (6f), Attack (5f) | **tamam** |
| Kültist Tarikat Üyesi | — | — | — | beklemede |
| Kültist Okçu | — | — | — | beklemede |
| Ele Geçirilmiş Eser | — | — | — | beklemede |
| Tarikat Gardiyanı | — | — | — | beklemede |

### Bosslar (Objeler)
| İsim | ID | Durum |
|------|----|-------|
| Sessiz Kâhin | — | beklemede |
| Kulaksız Kral | — | beklemede |
| Bin Dilli Anne | — | beklemede |
| Gözetleyen | — | beklemede |

### Tilesetler
| Bölge | ID | Durum |
|-------|----|-------|
| Bölge 1 — İşçilerin Mezarı | `99e4fd6d-c197-491a-8ae4-2ccdb893ad3f` | **tamam** — `assets/sprites/tilesets/zone1_surface_ruins/` |
| Bölge 2 — Yankı Şehri | `5625a822-b4f3-45c4-9eda-0d2744ccdef0` | **tamam** — `assets/sprites/tilesets/zone2_cave_ruins/` |
| Bölge 3 — Kör Rahipler Manastırı | — | beklemede |
| Bölge 4 — Ters Saray | — | beklemede |
| Bölge 5 — Son Çan Kuyusu | — | beklemede |

### Prop'lar / Harita Objeleri
| Prop | ID | Durum |
|------|----|-------|
| Duvar Meşalesi | — | beklemede |
| Sunak | — | beklemede |
| Kitaplık | — | beklemede |
| Lore Parşömeni | — | beklemede |
| Kaldıraç | — | beklemede |
| Sandık | — | beklemede |
| Kırık Sütun | — | beklemede |
| Kült Sembolü | — | beklemede |
| Sivri Tuzak | — | beklemede |

---

## PixelLab Araç Başvurusu

| İhtiyaç | Araç |
|---------|------|
| Yeni karakter sprite'ı | `create_character` |
| Yürüyüş/koşu/saldırı animasyonu | `animate_character` |
| Karakter işi tamamlandı mı? | `get_character` |
| Bölge platform tile'ları | `create_sidescroller_tileset` |
| Tileset üretim durumu | `get_sidescroller_tileset` |
| Prop (meşale, sandık, sunak) | `create_map_object` |
| Boss veya karmaşık düşman sprite'ı | `create_object` |
| Boss/obje animasyonu | `animate_object` |
| Düşman renk/detay varyantı | `vary_object` |
| Tüm karakterleri listele | `list_characters` |
| Tüm tilesetleri listele | `list_sidescroller_tilesets` |
| Tüm objeleri listele | `list_objects` |

---

*Bu dosya projenin yaşayan belgesidir. Asset ID'lerini, görev onay kutularını ve bölge durumlarını geliştirme ilerledikçe güncelle.*
