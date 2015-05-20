# MT940_to_OFX (compatible with Xero)

We use this script to convert Dutch MT940 files to OFX files, in such a way that they can be imported by the accounting software **Xero**. At the request of other Dutch Xero users, we published the script on this site.


## Setup

##### Requirements

* Ruby 2.x
* RubyGems
* Bundler

##### Clone Git Repository

This application may be cloned or downloaded from GitHub:

```
git clone https://github.com/bluesnotred/mt940_to_ofx.git
```

##### Install Gems

```
bundle install
```

## Usage

Use the script like this  :

```sh
$ ruby mt2ofx.rb my_mt940_file.940
```
The script will create *my_mt940_file.940.ofx* in response.
