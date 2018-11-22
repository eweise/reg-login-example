CREATE TABLE TODO (
    id uuid PRIMARY KEY,
    user_id uuid NOT NULL REFERENCES person (id),
    title text NOT NULL,
    details text NULL,
    due_date timestamp,
    complete bool NOT NULL,
    created_at timestamp NOT NULL,
    modified_at timestamp NOT NULL
);