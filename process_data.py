import json
from bson import ObjectId

# Excel data extracted from the attachment
excel_data = [
    ('awake', 'silent final e rule number one. Proximity to say "uh wake".', 'http://res.cloudinary.com/dytzehkji/image/upload/awake_tg6lbx.png'),
    ('bake', 'Second sound of \'a\' because of silent final e rule number one.', 'http://res.cloudinary.com/dytzehkji/image/upload/bake_tkypok.png'),
    ('bane', 'Second sound of \'a\' because of silent final e rule number one.', 'http://res.cloudinary.com/dytzehkji/image/upload/bane_ha5vfb.png'),
    ('barely', 'Second sound of \'a\' because of silent final e rule number one, fourth sound of \'y\' because it comes at the end of a multiple-syllable word.', 'http://res.cloudinary.com/dytzehkji/image/upload/barely_lsmufu.png'),
    ('beetle', 'Phonogram \'ee\', silent final e rule number four, all English syllables must have a written vowel.', 'http://res.cloudinary.com/dytzehkji/image/upload/beetle_thvso.png'),
    ('berry', 'Fourth sound of \'y\' because it comes at the end of a multiple-syllable word.', 'http://res.cloudinary.com/dytzehkji/image/upload/berry_ubugkf.png'),
    ('Blake', 'Second sound of \'a\' because of silent final e rule number one.', 'http://res.cloudinary.com/dytzehkji/image/upload/Blake_vg8qod.png'),
    ('bode', 'Second sound of \'o\' because of silent final e rule number one.', 'http://res.cloudinary.com/dytzehkji/image/upload/bode_d2z7va.png'),
    ('bomb', 'Silent \'b\'.', 'http://res.cloudinary.com/dytzehkji/image/upload/bomb_dmevnx.png'),
    ('brake', 'Second sound of \'a\' because of silent final e rule number one.', 'http://res.cloudinary.com/dytzehkji/image/upload/brake_hv2xsl.png'),
    ('breeze', 'Phonogram \'ee\', silent final e rule number five, no job e', 'http://res.cloudinary.com/dytzehkji/image/upload/breeze_viyowt.png'),
    ('bride', 'Second sound of \'i\' because of silent final e rule number one.', 'http://res.cloudinary.com/dytzehkji/image/upload/bride_cg4dey.png'),
    ('cake', 'Second sound of \'a\' because of silent final e rule number one.', 'http://res.cloudinary.com/dytzehkji/image/upload/cake_y3xjrd.png'),
    ('call', 'Third sound of \'a\'. Phonogram \'a\' may say its third sound before an \'l\'.', 'http://res.cloudinary.com/dytzehkji/image/upload/call_f6rltp.png'),
]

# Read existing data.json
with open('assets/data/data.json', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Create new entries with MongoDB ObjectIDs
for word, decoded_info, image_url in excel_data:
    new_entry = {
        '_id': {'$oid': str(ObjectId())},
        'word': word,
        'decodedInfo': decoded_info,
        'imageUrl': image_url,
        'audio_url': ''
    }
    data['words'].append(new_entry)

# Write updated data back to file
with open('assets/data/data.json', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print(f'Successfully added {len(excel_data)} new entries to data.json')
