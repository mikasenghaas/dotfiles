function envup --description 'Load ~/.env (1Password FIFO) into the current fish shell'
    set -l envfile $argv[1]
    test -z "$envfile"; and set envfile ~/.env

    if not test -p $envfile -o -f $envfile
        echo "envup: $envfile not found (is 1Password running?)" >&2
        return 1
    end

    set -l count 0
    while read -l line
        # strip optional leading `export `
        set line (string replace -r '^\s*export\s+' '' -- $line)
        set -l kv (string split -m 1 '=' -- $line)
        test (count $kv) -eq 2; or continue
        set -l name $kv[1]
        set -l value (string trim -c '"\'' -- $kv[2])
        string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' -- $name; or continue
        set -gx $name $value
        set count (math $count + 1)
    end < $envfile
    echo "envup: loaded $count vars from $envfile"
end
