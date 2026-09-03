# util

## generate_categories.py

Regenerates the FortiGuard and Application category locals from the live FortiSASE
API instead of maintaining them by hand:

- `modules/security/locals-categories_fgd.tf`
- `modules/security/locals-categories_app.tf`

Every category is emitted as `monitor`; the default-block (unsecure) set and the
`*_restricted_categories` variables still force `block` as before. New categories
Fortinet adds show up automatically as `monitor`.

### Usage

```bash
export TF_VAR_username=...   # FortiSASE API user (same creds as api/delete_all.py)
export TF_VAR_password=...

python util/generate_categories.py            # rewrite the two .tf files
python util/generate_categories.py --stdout   # dry run, print only
```

Default-block categories live in `DEFAULT_BLOCK_FGD` / `DEFAULT_BLOCK_APP` in the
script — review them when new categories appear.
