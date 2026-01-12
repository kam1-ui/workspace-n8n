--
-- PostgreSQL database dump
--

\restrict 9r8SDNEF3KzTYPhUwYLih07FWBnqRER44CkNmawm13Wj3ju4QKEqdISbyjLfk7T

-- Dumped from database version 15.15 (Debian 15.15-1.pgdg13+1)
-- Dumped by pg_dump version 15.15 (Debian 15.15-1.pgdg13+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: increment_workflow_version(); Type: FUNCTION; Schema: public; Owner: n8n
--

CREATE FUNCTION public.increment_workflow_version() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
			BEGIN
				IF NEW."versionCounter" IS NOT DISTINCT FROM OLD."versionCounter" THEN
					NEW."versionCounter" = OLD."versionCounter" + 1;
				END IF;
				RETURN NEW;
			END;
			$$;


ALTER FUNCTION public.increment_workflow_version() OWNER TO n8n;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: annotation_tag_entity; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.annotation_tag_entity (
    id character varying(16) NOT NULL,
    name character varying(24) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.annotation_tag_entity OWNER TO n8n;

--
-- Name: auth_identity; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.auth_identity (
    "userId" uuid,
    "providerId" character varying(64) NOT NULL,
    "providerType" character varying(32) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.auth_identity OWNER TO n8n;

--
-- Name: auth_provider_sync_history; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.auth_provider_sync_history (
    id integer NOT NULL,
    "providerType" character varying(32) NOT NULL,
    "runMode" text NOT NULL,
    status text NOT NULL,
    "startedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    "endedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    scanned integer NOT NULL,
    created integer NOT NULL,
    updated integer NOT NULL,
    disabled integer NOT NULL,
    error text
);


ALTER TABLE public.auth_provider_sync_history OWNER TO n8n;

--
-- Name: auth_provider_sync_history_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.auth_provider_sync_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.auth_provider_sync_history_id_seq OWNER TO n8n;

--
-- Name: auth_provider_sync_history_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.auth_provider_sync_history_id_seq OWNED BY public.auth_provider_sync_history.id;


--
-- Name: binary_data; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.binary_data (
    "fileId" uuid NOT NULL,
    "sourceType" character varying(50) NOT NULL,
    "sourceId" character varying(255) NOT NULL,
    data bytea NOT NULL,
    "mimeType" character varying(255),
    "fileName" character varying(255),
    "fileSize" integer NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    CONSTRAINT "CHK_binary_data_sourceType" CHECK ((("sourceType")::text = ANY ((ARRAY['execution'::character varying, 'chat_message_attachment'::character varying])::text[])))
);


ALTER TABLE public.binary_data OWNER TO n8n;

--
-- Name: COLUMN binary_data."sourceType"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.binary_data."sourceType" IS 'Source the file belongs to, e.g. ''execution''';


--
-- Name: COLUMN binary_data."sourceId"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.binary_data."sourceId" IS 'ID of the source, e.g. execution ID';


--
-- Name: COLUMN binary_data.data; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.binary_data.data IS 'Raw, not base64 encoded';


--
-- Name: COLUMN binary_data."fileSize"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.binary_data."fileSize" IS 'In bytes';


--
-- Name: chat_hub_agents; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.chat_hub_agents (
    id uuid NOT NULL,
    name character varying(256) NOT NULL,
    description character varying(512),
    "systemPrompt" text NOT NULL,
    "ownerId" uuid NOT NULL,
    "credentialId" character varying(36),
    provider character varying(16) NOT NULL,
    model character varying(64) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    tools json DEFAULT '[]'::json NOT NULL
);


ALTER TABLE public.chat_hub_agents OWNER TO n8n;

--
-- Name: COLUMN chat_hub_agents.provider; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_agents.provider IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';


--
-- Name: COLUMN chat_hub_agents.model; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_agents.model IS 'Model name used at the respective Model node, ie. "gpt-4"';


--
-- Name: COLUMN chat_hub_agents.tools; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_agents.tools IS 'Tools available to the agent as JSON node definitions';


--
-- Name: chat_hub_messages; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.chat_hub_messages (
    id uuid NOT NULL,
    "sessionId" uuid NOT NULL,
    "previousMessageId" uuid,
    "revisionOfMessageId" uuid,
    "retryOfMessageId" uuid,
    type character varying(16) NOT NULL,
    name character varying(128) NOT NULL,
    content text NOT NULL,
    provider character varying(16),
    model character varying(64),
    "workflowId" character varying(36),
    "executionId" integer,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "agentId" character varying(36),
    status character varying(16) DEFAULT 'success'::character varying NOT NULL,
    attachments json
);


ALTER TABLE public.chat_hub_messages OWNER TO n8n;

--
-- Name: COLUMN chat_hub_messages.type; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_messages.type IS 'ChatHubMessageType enum: "human", "ai", "system", "tool", "generic"';


--
-- Name: COLUMN chat_hub_messages.provider; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_messages.provider IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';


--
-- Name: COLUMN chat_hub_messages.model; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_messages.model IS 'Model name used at the respective Model node, ie. "gpt-4"';


--
-- Name: COLUMN chat_hub_messages."agentId"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_messages."agentId" IS 'ID of the custom agent (if provider is "custom-agent")';


--
-- Name: COLUMN chat_hub_messages.status; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_messages.status IS 'ChatHubMessageStatus enum, eg. "success", "error", "running", "cancelled"';


--
-- Name: COLUMN chat_hub_messages.attachments; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_messages.attachments IS 'File attachments for the message (if any), stored as JSON. Files are stored as base64-encoded data URLs.';


--
-- Name: chat_hub_sessions; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.chat_hub_sessions (
    id uuid NOT NULL,
    title character varying(256) NOT NULL,
    "ownerId" uuid NOT NULL,
    "lastMessageAt" timestamp(3) with time zone,
    "credentialId" character varying(36),
    provider character varying(16),
    model character varying(64),
    "workflowId" character varying(36),
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "agentId" character varying(36),
    "agentName" character varying(128),
    tools json DEFAULT '[]'::json NOT NULL
);


ALTER TABLE public.chat_hub_sessions OWNER TO n8n;

--
-- Name: COLUMN chat_hub_sessions.provider; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_sessions.provider IS 'ChatHubProvider enum: "openai", "anthropic", "google", "n8n"';


--
-- Name: COLUMN chat_hub_sessions.model; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_sessions.model IS 'Model name used at the respective Model node, ie. "gpt-4"';


--
-- Name: COLUMN chat_hub_sessions."agentId"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_sessions."agentId" IS 'ID of the custom agent (if provider is "custom-agent")';


--
-- Name: COLUMN chat_hub_sessions."agentName"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_sessions."agentName" IS 'Cached name of the custom agent (if provider is "custom-agent")';


--
-- Name: COLUMN chat_hub_sessions.tools; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.chat_hub_sessions.tools IS 'Tools available to the agent as JSON node definitions';


--
-- Name: credentials_entity; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.credentials_entity (
    name character varying(128) NOT NULL,
    data text NOT NULL,
    type character varying(128) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    id character varying(36) NOT NULL,
    "isManaged" boolean DEFAULT false NOT NULL,
    "isGlobal" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.credentials_entity OWNER TO n8n;

--
-- Name: data_table; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.data_table (
    id character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    "projectId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.data_table OWNER TO n8n;

--
-- Name: data_table_column; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.data_table_column (
    id character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    type character varying(32) NOT NULL,
    index integer NOT NULL,
    "dataTableId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.data_table_column OWNER TO n8n;

--
-- Name: COLUMN data_table_column.type; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.data_table_column.type IS 'Expected: string, number, boolean, or date (not enforced as a constraint)';


--
-- Name: COLUMN data_table_column.index; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.data_table_column.index IS 'Column order, starting from 0 (0 = first column)';


--
-- Name: event_destinations; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.event_destinations (
    id uuid NOT NULL,
    destination jsonb NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.event_destinations OWNER TO n8n;

--
-- Name: execution_annotation_tags; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.execution_annotation_tags (
    "annotationId" integer NOT NULL,
    "tagId" character varying(24) NOT NULL
);


ALTER TABLE public.execution_annotation_tags OWNER TO n8n;

--
-- Name: execution_annotations; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.execution_annotations (
    id integer NOT NULL,
    "executionId" integer NOT NULL,
    vote character varying(6),
    note text,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.execution_annotations OWNER TO n8n;

--
-- Name: execution_annotations_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.execution_annotations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.execution_annotations_id_seq OWNER TO n8n;

--
-- Name: execution_annotations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.execution_annotations_id_seq OWNED BY public.execution_annotations.id;


--
-- Name: execution_data; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.execution_data (
    "executionId" integer NOT NULL,
    "workflowData" json NOT NULL,
    data text NOT NULL
);


ALTER TABLE public.execution_data OWNER TO n8n;

--
-- Name: execution_entity; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.execution_entity (
    id integer NOT NULL,
    finished boolean NOT NULL,
    mode character varying NOT NULL,
    "retryOf" character varying,
    "retrySuccessId" character varying,
    "startedAt" timestamp(3) with time zone,
    "stoppedAt" timestamp(3) with time zone,
    "waitTill" timestamp(3) with time zone,
    status character varying NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "deletedAt" timestamp(3) with time zone,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.execution_entity OWNER TO n8n;

--
-- Name: execution_entity_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.execution_entity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.execution_entity_id_seq OWNER TO n8n;

--
-- Name: execution_entity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.execution_entity_id_seq OWNED BY public.execution_entity.id;


--
-- Name: execution_metadata; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.execution_metadata (
    id integer NOT NULL,
    "executionId" integer NOT NULL,
    key character varying(255) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.execution_metadata OWNER TO n8n;

--
-- Name: execution_metadata_temp_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.execution_metadata_temp_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.execution_metadata_temp_id_seq OWNER TO n8n;

--
-- Name: execution_metadata_temp_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.execution_metadata_temp_id_seq OWNED BY public.execution_metadata.id;


--
-- Name: folder; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.folder (
    id character varying(36) NOT NULL,
    name character varying(128) NOT NULL,
    "parentFolderId" character varying(36),
    "projectId" character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.folder OWNER TO n8n;

--
-- Name: folder_tag; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.folder_tag (
    "folderId" character varying(36) NOT NULL,
    "tagId" character varying(36) NOT NULL
);


ALTER TABLE public.folder_tag OWNER TO n8n;

--
-- Name: insights_by_period; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.insights_by_period (
    id integer NOT NULL,
    "metaId" integer NOT NULL,
    type integer NOT NULL,
    value bigint NOT NULL,
    "periodUnit" integer NOT NULL,
    "periodStart" timestamp(0) with time zone DEFAULT CURRENT_TIMESTAMP
);


ALTER TABLE public.insights_by_period OWNER TO n8n;

--
-- Name: COLUMN insights_by_period.type; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.insights_by_period.type IS '0: time_saved_minutes, 1: runtime_milliseconds, 2: success, 3: failure';


--
-- Name: COLUMN insights_by_period."periodUnit"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.insights_by_period."periodUnit" IS '0: hour, 1: day, 2: week';


--
-- Name: insights_by_period_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

ALTER TABLE public.insights_by_period ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.insights_by_period_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insights_metadata; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.insights_metadata (
    "metaId" integer NOT NULL,
    "workflowId" character varying(16),
    "projectId" character varying(36),
    "workflowName" character varying(128) NOT NULL,
    "projectName" character varying(255) NOT NULL
);


ALTER TABLE public.insights_metadata OWNER TO n8n;

--
-- Name: insights_metadata_metaId_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

ALTER TABLE public.insights_metadata ALTER COLUMN "metaId" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public."insights_metadata_metaId_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: insights_raw; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.insights_raw (
    id integer NOT NULL,
    "metaId" integer NOT NULL,
    type integer NOT NULL,
    value bigint NOT NULL,
    "timestamp" timestamp(0) with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.insights_raw OWNER TO n8n;

--
-- Name: COLUMN insights_raw.type; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.insights_raw.type IS '0: time_saved_minutes, 1: runtime_milliseconds, 2: success, 3: failure';


--
-- Name: insights_raw_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

ALTER TABLE public.insights_raw ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.insights_raw_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: installed_nodes; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.installed_nodes (
    name character varying(200) NOT NULL,
    type character varying(200) NOT NULL,
    "latestVersion" integer DEFAULT 1 NOT NULL,
    package character varying(241) NOT NULL
);


ALTER TABLE public.installed_nodes OWNER TO n8n;

--
-- Name: installed_packages; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.installed_packages (
    "packageName" character varying(214) NOT NULL,
    "installedVersion" character varying(50) NOT NULL,
    "authorName" character varying(70),
    "authorEmail" character varying(70),
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.installed_packages OWNER TO n8n;

--
-- Name: invalid_auth_token; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.invalid_auth_token (
    token character varying(512) NOT NULL,
    "expiresAt" timestamp(3) with time zone NOT NULL
);


ALTER TABLE public.invalid_auth_token OWNER TO n8n;

--
-- Name: migrations; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    "timestamp" bigint NOT NULL,
    name character varying NOT NULL
);


ALTER TABLE public.migrations OWNER TO n8n;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.migrations_id_seq OWNER TO n8n;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: n8n
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: oauth_access_tokens; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.oauth_access_tokens (
    token character varying NOT NULL,
    "clientId" character varying NOT NULL,
    "userId" uuid NOT NULL
);


ALTER TABLE public.oauth_access_tokens OWNER TO n8n;

--
-- Name: oauth_authorization_codes; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.oauth_authorization_codes (
    code character varying(255) NOT NULL,
    "clientId" character varying NOT NULL,
    "userId" uuid NOT NULL,
    "redirectUri" character varying NOT NULL,
    "codeChallenge" character varying NOT NULL,
    "codeChallengeMethod" character varying(255) NOT NULL,
    "expiresAt" bigint NOT NULL,
    state character varying,
    used boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.oauth_authorization_codes OWNER TO n8n;

--
-- Name: COLUMN oauth_authorization_codes."expiresAt"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.oauth_authorization_codes."expiresAt" IS 'Unix timestamp in milliseconds';


--
-- Name: oauth_clients; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.oauth_clients (
    id character varying NOT NULL,
    name character varying(255) NOT NULL,
    "redirectUris" json NOT NULL,
    "grantTypes" json NOT NULL,
    "clientSecret" character varying(255),
    "clientSecretExpiresAt" bigint,
    "tokenEndpointAuthMethod" character varying(255) DEFAULT 'none'::character varying NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.oauth_clients OWNER TO n8n;

--
-- Name: COLUMN oauth_clients."tokenEndpointAuthMethod"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.oauth_clients."tokenEndpointAuthMethod" IS 'Possible values: none, client_secret_basic or client_secret_post';


--
-- Name: oauth_refresh_tokens; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.oauth_refresh_tokens (
    token character varying(255) NOT NULL,
    "clientId" character varying NOT NULL,
    "userId" uuid NOT NULL,
    "expiresAt" bigint NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.oauth_refresh_tokens OWNER TO n8n;

--
-- Name: COLUMN oauth_refresh_tokens."expiresAt"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.oauth_refresh_tokens."expiresAt" IS 'Unix timestamp in milliseconds';


--
-- Name: oauth_user_consents; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.oauth_user_consents (
    id integer NOT NULL,
    "userId" uuid NOT NULL,
    "clientId" character varying NOT NULL,
    "grantedAt" bigint NOT NULL
);


ALTER TABLE public.oauth_user_consents OWNER TO n8n;

--
-- Name: COLUMN oauth_user_consents."grantedAt"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.oauth_user_consents."grantedAt" IS 'Unix timestamp in milliseconds';


--
-- Name: oauth_user_consents_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

ALTER TABLE public.oauth_user_consents ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.oauth_user_consents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: processed_data; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.processed_data (
    "workflowId" character varying(36) NOT NULL,
    context character varying(255) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    value text NOT NULL
);


ALTER TABLE public.processed_data OWNER TO n8n;

--
-- Name: project; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.project (
    id character varying(36) NOT NULL,
    name character varying(255) NOT NULL,
    type character varying(36) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    icon json,
    description character varying(512)
);


ALTER TABLE public.project OWNER TO n8n;

--
-- Name: project_relation; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.project_relation (
    "projectId" character varying(36) NOT NULL,
    "userId" uuid NOT NULL,
    role character varying NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.project_relation OWNER TO n8n;

--
-- Name: role; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.role (
    slug character varying(128) NOT NULL,
    "displayName" text,
    description text,
    "roleType" text,
    "systemRole" boolean DEFAULT false NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.role OWNER TO n8n;

--
-- Name: COLUMN role.slug; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.role.slug IS 'Unique identifier of the role for example: "global:owner"';


--
-- Name: COLUMN role."displayName"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.role."displayName" IS 'Name used to display in the UI';


--
-- Name: COLUMN role.description; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.role.description IS 'Text describing the scope in more detail of users';


--
-- Name: COLUMN role."roleType"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.role."roleType" IS 'Type of the role, e.g., global, project, or workflow';


--
-- Name: COLUMN role."systemRole"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.role."systemRole" IS 'Indicates if the role is managed by the system and cannot be edited';


--
-- Name: role_scope; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.role_scope (
    "roleSlug" character varying(128) NOT NULL,
    "scopeSlug" character varying(128) NOT NULL
);


ALTER TABLE public.role_scope OWNER TO n8n;

--
-- Name: scope; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.scope (
    slug character varying(128) NOT NULL,
    "displayName" text,
    description text
);


ALTER TABLE public.scope OWNER TO n8n;

--
-- Name: COLUMN scope.slug; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.scope.slug IS 'Unique identifier of the scope for example: "project:create"';


--
-- Name: COLUMN scope."displayName"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.scope."displayName" IS 'Name used to display in the UI';


--
-- Name: COLUMN scope.description; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.scope.description IS 'Text describing the scope in more detail of users';


--
-- Name: settings; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.settings (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    "loadOnStartup" boolean DEFAULT false NOT NULL
);


ALTER TABLE public.settings OWNER TO n8n;

--
-- Name: shared_credentials; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.shared_credentials (
    "credentialsId" character varying(36) NOT NULL,
    "projectId" character varying(36) NOT NULL,
    role text NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.shared_credentials OWNER TO n8n;

--
-- Name: shared_workflow; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.shared_workflow (
    "workflowId" character varying(36) NOT NULL,
    "projectId" character varying(36) NOT NULL,
    role text NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.shared_workflow OWNER TO n8n;

--
-- Name: tag_entity; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.tag_entity (
    name character varying(24) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    id character varying(36) NOT NULL
);


ALTER TABLE public.tag_entity OWNER TO n8n;

--
-- Name: test_case_execution; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.test_case_execution (
    id character varying(36) NOT NULL,
    "testRunId" character varying(36) NOT NULL,
    "executionId" integer,
    status character varying NOT NULL,
    "runAt" timestamp(3) with time zone,
    "completedAt" timestamp(3) with time zone,
    "errorCode" character varying,
    "errorDetails" json,
    metrics json,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    inputs json,
    outputs json
);


ALTER TABLE public.test_case_execution OWNER TO n8n;

--
-- Name: test_run; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.test_run (
    id character varying(36) NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    status character varying NOT NULL,
    "errorCode" character varying,
    "errorDetails" json,
    "runAt" timestamp(3) with time zone,
    "completedAt" timestamp(3) with time zone,
    metrics json,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.test_run OWNER TO n8n;

--
-- Name: user; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public."user" (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    email character varying(255),
    "firstName" character varying(32),
    "lastName" character varying(32),
    password character varying(255),
    "personalizationAnswers" json,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    settings json,
    disabled boolean DEFAULT false NOT NULL,
    "mfaEnabled" boolean DEFAULT false NOT NULL,
    "mfaSecret" text,
    "mfaRecoveryCodes" text,
    "lastActiveAt" date,
    "roleSlug" character varying(128) DEFAULT 'global:member'::character varying NOT NULL
);


ALTER TABLE public."user" OWNER TO n8n;

--
-- Name: user_api_keys; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.user_api_keys (
    id character varying(36) NOT NULL,
    "userId" uuid NOT NULL,
    label character varying(100) NOT NULL,
    "apiKey" character varying NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    scopes json,
    audience character varying DEFAULT 'public-api'::character varying NOT NULL
);


ALTER TABLE public.user_api_keys OWNER TO n8n;

--
-- Name: variables; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.variables (
    key character varying(50) NOT NULL,
    type character varying(50) DEFAULT 'string'::character varying NOT NULL,
    value character varying(255),
    id character varying(36) NOT NULL,
    "projectId" character varying(36)
);


ALTER TABLE public.variables OWNER TO n8n;

--
-- Name: webhook_entity; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.webhook_entity (
    "webhookPath" character varying NOT NULL,
    method character varying NOT NULL,
    node character varying NOT NULL,
    "webhookId" character varying,
    "pathLength" integer,
    "workflowId" character varying(36) NOT NULL
);


ALTER TABLE public.webhook_entity OWNER TO n8n;

--
-- Name: workflow_dependency; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.workflow_dependency (
    id integer NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "workflowVersionId" integer NOT NULL,
    "dependencyType" character varying(32) NOT NULL,
    "dependencyKey" character varying(255) NOT NULL,
    "dependencyInfo" json,
    "indexVersionId" smallint DEFAULT 1 NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL
);


ALTER TABLE public.workflow_dependency OWNER TO n8n;

--
-- Name: COLUMN workflow_dependency."workflowVersionId"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.workflow_dependency."workflowVersionId" IS 'Version of the workflow';


--
-- Name: COLUMN workflow_dependency."dependencyType"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.workflow_dependency."dependencyType" IS 'Type of dependency: "credential", "nodeType", "webhookPath", or "workflowCall"';


--
-- Name: COLUMN workflow_dependency."dependencyKey"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.workflow_dependency."dependencyKey" IS 'ID or name of the dependency';


--
-- Name: COLUMN workflow_dependency."dependencyInfo"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.workflow_dependency."dependencyInfo" IS 'Additional info about the dependency, interpreted based on type';


--
-- Name: COLUMN workflow_dependency."indexVersionId"; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.workflow_dependency."indexVersionId" IS 'Version of the index structure';


--
-- Name: workflow_dependency_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

ALTER TABLE public.workflow_dependency ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.workflow_dependency_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: workflow_entity; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.workflow_entity (
    name character varying(128) NOT NULL,
    active boolean NOT NULL,
    nodes json NOT NULL,
    connections json NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    settings json,
    "staticData" json,
    "pinData" json,
    "versionId" character(36) NOT NULL,
    "triggerCount" integer DEFAULT 0 NOT NULL,
    id character varying(36) NOT NULL,
    meta json,
    "parentFolderId" character varying(36) DEFAULT NULL::character varying,
    "isArchived" boolean DEFAULT false NOT NULL,
    "versionCounter" integer DEFAULT 1 NOT NULL,
    description text,
    "activeVersionId" character varying(36)
);


ALTER TABLE public.workflow_entity OWNER TO n8n;

--
-- Name: workflow_history; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.workflow_history (
    "versionId" character varying(36) NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    authors character varying(255) NOT NULL,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    "updatedAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    nodes json NOT NULL,
    connections json NOT NULL,
    name character varying(128),
    autosaved boolean DEFAULT false NOT NULL,
    description text
);


ALTER TABLE public.workflow_history OWNER TO n8n;

--
-- Name: workflow_publish_history; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.workflow_publish_history (
    id integer NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "versionId" character varying(36) NOT NULL,
    event character varying(36) NOT NULL,
    "userId" uuid,
    "createdAt" timestamp(3) with time zone DEFAULT CURRENT_TIMESTAMP(3) NOT NULL,
    CONSTRAINT "CHK_workflow_publish_history_event" CHECK (((event)::text = ANY ((ARRAY['activated'::character varying, 'deactivated'::character varying])::text[])))
);


ALTER TABLE public.workflow_publish_history OWNER TO n8n;

--
-- Name: COLUMN workflow_publish_history.event; Type: COMMENT; Schema: public; Owner: n8n
--

COMMENT ON COLUMN public.workflow_publish_history.event IS 'Type of history record: activated (workflow is now active), deactivated (workflow is now inactive)';


--
-- Name: workflow_publish_history_id_seq; Type: SEQUENCE; Schema: public; Owner: n8n
--

ALTER TABLE public.workflow_publish_history ALTER COLUMN id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME public.workflow_publish_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: workflow_statistics; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.workflow_statistics (
    count integer DEFAULT 0,
    "latestEvent" timestamp(3) with time zone,
    name character varying(128) NOT NULL,
    "workflowId" character varying(36) NOT NULL,
    "rootCount" integer DEFAULT 0
);


ALTER TABLE public.workflow_statistics OWNER TO n8n;

--
-- Name: workflows_tags; Type: TABLE; Schema: public; Owner: n8n
--

CREATE TABLE public.workflows_tags (
    "workflowId" character varying(36) NOT NULL,
    "tagId" character varying(36) NOT NULL
);


ALTER TABLE public.workflows_tags OWNER TO n8n;

--
-- Name: auth_provider_sync_history id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.auth_provider_sync_history ALTER COLUMN id SET DEFAULT nextval('public.auth_provider_sync_history_id_seq'::regclass);


--
-- Name: execution_annotations id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_annotations ALTER COLUMN id SET DEFAULT nextval('public.execution_annotations_id_seq'::regclass);


--
-- Name: execution_entity id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_entity ALTER COLUMN id SET DEFAULT nextval('public.execution_entity_id_seq'::regclass);


--
-- Name: execution_metadata id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_metadata ALTER COLUMN id SET DEFAULT nextval('public.execution_metadata_temp_id_seq'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Data for Name: annotation_tag_entity; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.annotation_tag_entity (id, name, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: auth_identity; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.auth_identity ("userId", "providerId", "providerType", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: auth_provider_sync_history; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.auth_provider_sync_history (id, "providerType", "runMode", status, "startedAt", "endedAt", scanned, created, updated, disabled, error) FROM stdin;
\.


--
-- Data for Name: binary_data; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.binary_data ("fileId", "sourceType", "sourceId", data, "mimeType", "fileName", "fileSize", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: chat_hub_agents; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.chat_hub_agents (id, name, description, "systemPrompt", "ownerId", "credentialId", provider, model, "createdAt", "updatedAt", tools) FROM stdin;
\.


--
-- Data for Name: chat_hub_messages; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.chat_hub_messages (id, "sessionId", "previousMessageId", "revisionOfMessageId", "retryOfMessageId", type, name, content, provider, model, "workflowId", "executionId", "createdAt", "updatedAt", "agentId", status, attachments) FROM stdin;
\.


--
-- Data for Name: chat_hub_sessions; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.chat_hub_sessions (id, title, "ownerId", "lastMessageAt", "credentialId", provider, model, "workflowId", "createdAt", "updatedAt", "agentId", "agentName", tools) FROM stdin;
\.


--
-- Data for Name: credentials_entity; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.credentials_entity (name, data, type, "createdAt", "updatedAt", id, "isManaged", "isGlobal") FROM stdin;
Gemini 2.0 Flash API	U2FsdGVkX19sD+UrifSILv/YnNYEa6RdxtyAeUuSHv79fGSfY38JDnQ4NL3NAOF69T6E/Cdikr+LR85XZdrHrhr3joYnrLLaxWEzkhTOEG6e2MXwtz1Nr2QaUXhNBpwfSVFuKwdHZ7ceCrB4o67iHNnLjNlvFKoQknyADevZPnphU2NwAK1RXDFDTWmGcc/zrhjbtgsBD6CU6ZDYosohZnoZXKu2/53B++y7y/8Bgb8=	httpQueryAuth	2025-12-18 19:38:04.89+00	2025-12-19 08:42:08.086+00	I3D538Occ66Sb5YV	f	f
\.


--
-- Data for Name: data_table; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.data_table (id, name, "projectId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: data_table_column; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.data_table_column (id, name, type, index, "dataTableId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: event_destinations; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.event_destinations (id, destination, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: execution_annotation_tags; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.execution_annotation_tags ("annotationId", "tagId") FROM stdin;
\.


--
-- Data for Name: execution_annotations; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.execution_annotations (id, "executionId", vote, note, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: execution_data; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.execution_data ("executionId", "workflowData", data) FROM stdin;
1	{"id":"9dwHAWxj9YdjO2Ol","name":"Transcription YouTube - Gemini + Whisper","active":false,"activeVersionId":null,"nodes":[{"parameters":{"mode":"rules","rules":{"values":[{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":1},"conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}","id":"1deba6d9-96d6-4b10-9b2c-cc88230e573d"}],"combinator":"and"},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":1},"conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}","id":"3face287-9a3b-415f-9297-91447916b6de"}],"combinator":"and"},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"21749132-c2af-4323-b1dc-645b7238c503","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[544,448]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];","notice":""},"id":"45292cee-20dc-483d-abeb-0400c00c6b22","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[736,336]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"json","specifyBody":"keypair","bodyParameters":{"parameters":[{"name":"contents","value":"={{ [{\\"parts\\": [{\\"text\\": \\"Transcris cette vidéo en français. Retourne uniquement le texte de la transcription, sans aucun formatage ni commentaire.\\"}, {\\"fileData\\": {\\"mimeType\\": \\"video/mp4\\", \\"fileUri\\": \\"gs://temp-bucket/\\" + $json.video_id + \\".mp4\\"}}]}] }}"}]},"options":{"timeout":300000},"infoMessage":""},"id":"299dc582-ec89-498a-a1aa-9f9ceb74cc90","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[944,336],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Download Video (Gemini)').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"8627e11e-1e32-4985-b645-da1491cb50ca","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1136,336]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"d2a966b3-2197-468e-8ef4-affc8c1952f7","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[736,544]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"1d9c94a0-1779-4262-8499-0d54f1b6dfdd","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[944,544]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];","notice":""},"id":"ba87a30b-feaa-4d5e-8bb5-41b51436f4da","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1136,544]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"http://localhost:9000/transcribe","authentication":"none","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"parameterType":"formData","name":"language","value":"fr"}]},"options":{"timeout":3600000},"infoMessage":""},"id":"2b608ad9-67af-4905-a2ff-7d613b7b67fe","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1344,544]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"4cd1054d-67e3-44ed-bc51-c595d5700a80","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1536,544]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID1').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"8b44c4e3-6d59-4476-926e-23518679def1","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1344,448]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}","notice":""},"id":"4c62182f-e3bb-47cc-8efa-dbf977221895","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1536,448]},{"parameters":{"enableResponseOutput":false,"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"d4816c4b-8059-484a-b6d2-9b0fe1ff9e5c","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1744,448]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const body = $input.first().json.body;\\nconst youtubeUrl = body.youtube_url || body.url;\\nconst useGemini = body.use_gemini !== false;\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];","notice":""},"id":"4520f0bf-1111-42b1-8b7a-edf80f22d185","name":"Extraire Video ID1","type":"n8n-nodes-base.code","typeVersion":2,"position":[336,448]},{"parameters":{"notice":""},"type":"n8n-nodes-base.manualTrigger","typeVersion":1,"position":[144,448],"id":"8261ec82-31b4-40c0-a2ca-68d13d0d137c","name":"When clicking ‘Execute workflow’"}],"connections":{"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]},"Extraire Video ID1":{"main":[[{"node":"Switch","type":"main","index":0}]]},"When clicking ‘Execute workflow’":{"main":[[{"node":"Extraire Video ID1","type":"main","index":0}]]}},"settings":{"executionOrder":"v1","timeSavedMode":"fixed","callerPolicy":"workflowsFromSameOwner","executionTimeout":-1,"availableInMCP":true},"pinData":{}}	[{"version":1,"startData":"1","resultData":"2","executionData":"3"},{"destinationNode":"4","runNodeFilter":"5"},{"runData":"6","pinData":"7","lastNodeExecuted":"8"},{"contextData":"9","nodeExecutionStack":"10","metadata":"11","waitingExecution":"12","waitingExecutionSource":"13","runtimeData":"14"},{"nodeName":"8","mode":"15"},["8"],{"When clicking ‘Execute workflow’":"16"},{},"When clicking ‘Execute workflow’",{},[],{},{},{},{"version":1,"establishedAt":1766088053678,"source":"17"},"inclusive",["18"],"manual",{"startTime":1766088053680,"executionIndex":0,"source":"19","hints":"20","executionTime":3,"executionStatus":"21","data":"22"},[],[],"success",{"main":"23"},["24"],["25"],{"json":"26","pairedItem":"27"},{},{"item":0}]
2	{"id":"R31TqM6ks1cBpLkA","name":"Transcription YouTube - Gemini + Whisper","active":true,"activeVersionId":"58f1c494-b128-48b8-b0b9-e1102ca79c0b","isArchived":false,"createdAt":"2025-12-19T03:58:17.115Z","updatedAt":"2025-12-19T05:16:39.608Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"transcribe","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-001","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,400],"webhookId":"transcribe-youtube"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];","notice":""},"id":"extract-id-001","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,400]},{"parameters":{"mode":"rules","rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"switch-001","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[650,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];","notice":""},"id":"download-gemini-001","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,300]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"json","specifyBody":"keypair","bodyParameters":{"parameters":[{"name":"contents","value":"={{ [{\\"parts\\": [{\\"text\\": \\"Transcris cette vidéo en français. Retourne uniquement le texte de la transcription, sans aucun formatage ni commentaire.\\"}, {\\"fileData\\": {\\"mimeType\\": \\"video/mp4\\", \\"fileUri\\": \\"gs://temp-bucket/\\" + $json.video_id + \\".mp4\\"}}]}] }}"}]},"options":{"timeout":300000},"infoMessage":""},"id":"gemini-api-001","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1050,300],"credentials":{"httpQueryAuth":{"id":"gemini-api-key","name":"Gemini API Key"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Download Video (Gemini)').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"parse-gemini-001","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,300]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"download-whisper-001","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"extract-audio-001","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1050,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];","notice":""},"id":"read-audio-001","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,500]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"http://localhost:9000/transcribe","authentication":"none","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"parameterType":"formData","name":"language","value":"fr"}]},"options":{"timeout":3600000},"infoMessage":""},"id":"whisper-api-001","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1450,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"parse-whisper-001","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"save-files-001","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1450,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}","notice":""},"id":"cleanup-001","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,400]},{"parameters":{"enableResponseOutput":false,"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"response-001","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1850,400]}],"connections":{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1","callerPolicy":"workflowsFromSameOwner","availableInMCP":true,"timeSavedMode":"fixed"},"staticData":{},"pinData":null}	[{"version":1,"startData":"1","resultData":"2","executionData":"3"},{},{"error":"4","runData":"5","lastNodeExecuted":"6"},{"contextData":"7","nodeExecutionStack":"8","metadata":"9","waitingExecution":"10","waitingExecutionSource":"11","runtimeData":"12"},{"level":"13","tags":"14","description":null,"lineNumber":1,"message":"15","stack":"16"},{"Webhook":"17","Extraire Video ID":"18","Switch":"19","Download Video (Whisper)":"20"},"Download Video (Whisper)",{},["21"],{},{},{},{"version":1,"establishedAt":1766123618633,"source":"22"},"error",{},"Module 'child_process' is disallowed [line 1]","Error: Module 'child_process' is disallowed\\n    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/require-resolver.js:16:27\\n    at VmCodeWrapper (evalmachine.<anonymous>:1:251)\\n    at evalmachine.<anonymous>:16:2\\n    at Script.runInContext (node:vm:149:12)\\n    at runInContext (node:vm:301:6)\\n    at result (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:185:61)\\n    at new Promise (<anonymous>)\\n    at JsTaskRunner.runForAllItems (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:178:34)\\n    at JsTaskRunner.executeTask (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:128:26)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:105:5)",["23"],["24"],["25"],["26"],{"node":"27","data":"28","source":"29"},"webhook",{"startTime":1766123618634,"executionIndex":0,"source":"30","hints":"31","executionTime":0,"executionStatus":"32","data":"33"},{"startTime":1766123618635,"executionIndex":1,"source":"34","hints":"35","executionTime":54,"executionStatus":"32","data":"36"},{"startTime":1766123618689,"executionIndex":2,"source":"37","hints":"38","executionTime":6,"executionStatus":"32","data":"39"},{"startTime":1766123618695,"executionIndex":3,"source":"40","hints":"41","executionTime":11,"executionStatus":"13","error":"42"},{"parameters":"43","id":"44","name":"6","type":"45","typeVersion":2,"position":"46"},{"main":"47"},{"main":"40"},[],[],"success",{"main":"48"},["49"],[],{"main":"50"},["51"],[],{"main":"52"},["53"],[],{"level":"13","tags":"14","description":null,"lineNumber":1,"message":"15","stack":"16"},{"mode":"54","language":"55","jsCode":"56","notice":"57"},"download-whisper-001","n8n-nodes-base.code",[850,500],["58"],["59"],{"previousNode":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65","previousNodeOutput":1},"runOnceForAllItems","javaScript","const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];","",["66"],["67"],"Webhook",["68"],"Extraire Video ID",[],["69"],"Switch",{"json":"70","pairedItem":"71"},{"json":"72","pairedItem":"73"},{"json":"70","pairedItem":"74"},{"json":"70","pairedItem":"75"},{"youtube_url":"76","video_id":"77","use_gemini":false,"timestamp":"78"},{"item":0},{"headers":"79","params":"80","query":"81","body":"82","webhookUrl":"83","executionMode":"84"},{"item":0},{"item":0},{"item":0},"https://www.youtube.com/watch?v=dQw4w9WgXcQ","dQw4w9WgXcQ","2025-12-19T05:53:38.687Z",{"host":"85","user-agent":"86","content-length":"87","accept":"88","content-type":"89","x-forwarded-for":"90","x-forwarded-host":"85","x-forwarded-port":"91","x-forwarded-proto":"92","x-forwarded-server":"93","x-real-ip":"90","accept-encoding":"94"},{},{},{"method":"95","youtube_url":"76"},"http://localhost:5678/webhook/transcribe","production","n8n.chnnlcrypto.cloud","curl/8.5.0","80","*/*","application/json","72.60.175.177","443","https","8dfc70ce64c8","gzip","whisper"]
3	{"id":"R31TqM6ks1cBpLkA","name":"Transcription YouTube - Gemini + Whisper","active":true,"activeVersionId":"58f1c494-b128-48b8-b0b9-e1102ca79c0b","isArchived":false,"createdAt":"2025-12-19T03:58:17.115Z","updatedAt":"2025-12-19T05:16:39.608Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"transcribe","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"webhook-001","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,400],"webhookId":"transcribe-youtube"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];","notice":""},"id":"extract-id-001","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,400]},{"parameters":{"mode":"rules","rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"switch-001","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[650,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];","notice":""},"id":"download-gemini-001","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,300]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"json","specifyBody":"keypair","bodyParameters":{"parameters":[{"name":"contents","value":"={{ [{\\"parts\\": [{\\"text\\": \\"Transcris cette vidéo en français. Retourne uniquement le texte de la transcription, sans aucun formatage ni commentaire.\\"}, {\\"fileData\\": {\\"mimeType\\": \\"video/mp4\\", \\"fileUri\\": \\"gs://temp-bucket/\\" + $json.video_id + \\".mp4\\"}}]}] }}"}]},"options":{"timeout":300000},"infoMessage":""},"id":"gemini-api-001","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1050,300],"credentials":{"httpQueryAuth":{"id":"gemini-api-key","name":"Gemini API Key"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Download Video (Gemini)').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"parse-gemini-001","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,300]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"download-whisper-001","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"extract-audio-001","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1050,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];","notice":""},"id":"read-audio-001","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,500]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"http://localhost:9000/transcribe","authentication":"none","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"parameterType":"formData","name":"language","value":"fr"}]},"options":{"timeout":3600000},"infoMessage":""},"id":"whisper-api-001","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1450,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"parse-whisper-001","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"save-files-001","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1450,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}","notice":""},"id":"cleanup-001","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,400]},{"parameters":{"enableResponseOutput":false,"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"response-001","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1850,400]}],"connections":{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1","callerPolicy":"workflowsFromSameOwner","availableInMCP":true,"timeSavedMode":"fixed"},"staticData":{},"pinData":null}	[{"version":1,"startData":"1","resultData":"2","executionData":"3"},{},{"error":"4","runData":"5","lastNodeExecuted":"6"},{"contextData":"7","nodeExecutionStack":"8","metadata":"9","waitingExecution":"10","waitingExecutionSource":"11","runtimeData":"12"},{"level":"13","tags":"14","description":null,"lineNumber":1,"message":"15","stack":"16"},{"Webhook":"17","Extraire Video ID":"18","Switch":"19","Download Video (Whisper)":"20"},"Download Video (Whisper)",{},["21"],{},{},{},{"version":1,"establishedAt":1766123645369,"source":"22"},"error",{},"Module 'child_process' is disallowed [line 1]","Error: Module 'child_process' is disallowed\\n    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/require-resolver.js:16:27\\n    at VmCodeWrapper (evalmachine.<anonymous>:1:251)\\n    at evalmachine.<anonymous>:16:2\\n    at Script.runInContext (node:vm:149:12)\\n    at runInContext (node:vm:301:6)\\n    at result (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:185:61)\\n    at new Promise (<anonymous>)\\n    at JsTaskRunner.runForAllItems (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:178:34)\\n    at JsTaskRunner.executeTask (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:128:26)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:105:5)",["23"],["24"],["25"],["26"],{"node":"27","data":"28","source":"29"},"webhook",{"startTime":1766123645369,"executionIndex":0,"source":"30","hints":"31","executionTime":1,"executionStatus":"32","data":"33"},{"startTime":1766123645370,"executionIndex":1,"source":"34","hints":"35","executionTime":5,"executionStatus":"32","data":"36"},{"startTime":1766123645375,"executionIndex":2,"source":"37","hints":"38","executionTime":2,"executionStatus":"32","data":"39"},{"startTime":1766123645377,"executionIndex":3,"source":"40","hints":"41","executionTime":4,"executionStatus":"13","error":"42"},{"parameters":"43","id":"44","name":"6","type":"45","typeVersion":2,"position":"46"},{"main":"47"},{"main":"40"},[],[],"success",{"main":"48"},["49"],[],{"main":"50"},["51"],[],{"main":"52"},["53"],[],{"level":"13","tags":"14","description":null,"lineNumber":1,"message":"15","stack":"16"},{"mode":"54","language":"55","jsCode":"56","notice":"57"},"download-whisper-001","n8n-nodes-base.code",[850,500],["58"],["59"],{"previousNode":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65","previousNodeOutput":1},"runOnceForAllItems","javaScript","const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];","",["66"],["67"],"Webhook",["68"],"Extraire Video ID",[],["69"],"Switch",{"json":"70","pairedItem":"71"},{"json":"72","pairedItem":"73"},{"json":"70","pairedItem":"74"},{"json":"70","pairedItem":"75"},{"youtube_url":"76","video_id":"77","use_gemini":false,"timestamp":"78"},{"item":0},{"headers":"79","params":"80","query":"81","body":"82","webhookUrl":"83","executionMode":"84"},{"item":0},{"item":0},{"item":0},"https://www.youtube.com/watch?v=dQw4w9WgXcQ","dQw4w9WgXcQ","2025-12-19T05:54:05.375Z",{"host":"85","user-agent":"86","content-length":"87","accept":"88","content-type":"89","x-forwarded-for":"90","x-forwarded-host":"85","x-forwarded-port":"91","x-forwarded-proto":"92","x-forwarded-server":"93","x-real-ip":"90","accept-encoding":"94"},{},{},{"method":"95","youtube_url":"76"},"http://localhost:5678/webhook/transcribe","production","n8n.chnnlcrypto.cloud","curl/8.5.0","80","*/*","application/json","72.60.175.177","443","https","8dfc70ce64c8","gzip","whisper"]
4	{"id":"ccdNWghInvBMCrnH","name":"Transcription YouTube - Gemini + Whisper","active":true,"activeVersionId":"0b5bec6a-79f9-405b-8566-d059056d3baf","isArchived":false,"createdAt":"2025-12-19T05:51:36.677Z","updatedAt":"2025-12-19T06:26:14.064Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"transcribe","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"1dda2a0a-c0f7-427b-be08-96b16614a399","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[624,96],"webhookId":"transcribe-youtube"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];","notice":""},"id":"9a268a0d-d00a-4545-8e8c-0690806b597a","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[816,96]},{"parameters":{"mode":"rules","rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"ed604210-b9b5-4181-a835-ff7a3ff1742a","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[1024,96]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];","notice":""},"id":"c5bdbcc6-07ac-4ddd-8178-9e0b4514538e","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,-16]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];","notice":""},"id":"8b1394b5-337a-4863-aa2a-6bd952c32df9","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,-16]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","provideSslCertificates":false,"sendQuery":false,"sendHeaders":true,"specifyHeaders":"keypair","headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000},"infoMessage":""},"id":"49309b77-e1a5-4c63-b195-ef783d802f90","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1616,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];","notice":""},"id":"6fe03172-6867-45cf-b044-447c7f8291ea","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1824,-16]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"json","specifyBody":"keypair","bodyParameters":{"parameters":[{"name":"","value":""}]},"options":{"timeout":600000},"infoMessage":""},"id":"06308c22-4095-4e61-a832-9703720d6cbf","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[2016,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"d0a99abf-40a3-46c2-9ee0-23fd8bc94316","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2224,-16]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"847aa2d0-bace-4df8-aec4-91e01b05cf15","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `/home/ne0rignr/.local/bin/ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"b6e1e382-e7e5-42d1-95e7-a7067b6e11b1","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];","notice":""},"id":"4bdc2acd-cf3c-44cd-b19b-65b6d11e4522","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1616,192]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"http://localhost:9000/transcribe","authentication":"none","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"parameterType":"formData","name":"language","value":"fr"}]},"options":{"timeout":3600000},"infoMessage":""},"id":"6e7fd028-5580-42de-8087-eaf19079a765","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1824,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"57c973e5-b369-4d99-9b46-5b8f02549a96","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2016,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"d877c019-82fd-48de-8bec-6471f8328ca9","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[2416,96]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}","notice":""},"id":"7f55a96b-19fe-47f7-9c41-9f3d2ace4446","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[2624,96]},{"parameters":{"enableResponseOutput":false,"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"064bbacf-086b-46c6-9da4-55be014423ce","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[2816,96]}],"connections":{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1","timeSavedMode":"fixed","callerPolicy":"workflowsFromSameOwner","availableInMCP":true},"staticData":{},"pinData":{}}	[{"version":1,"startData":"1","resultData":"2","executionData":"3"},{},{"error":"4","runData":"5","lastNodeExecuted":"6"},{"contextData":"7","nodeExecutionStack":"8","metadata":"9","waitingExecution":"10","waitingExecutionSource":"11","runtimeData":"12"},{"level":"13","tags":"14","description":null,"lineNumber":1,"message":"15","stack":"16"},{"Webhook":"17","Extraire Video ID":"18","Switch":"19","Download Video (Gemini)":"20"},"Download Video (Gemini)",{},["21"],{},{},{},{"version":1,"establishedAt":1766125892702,"source":"22"},"error",{},"Module 'child_process' is disallowed [line 1]","Error: Module 'child_process' is disallowed\\n    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/require-resolver.js:16:27\\n    at VmCodeWrapper (evalmachine.<anonymous>:1:251)\\n    at evalmachine.<anonymous>:16:2\\n    at Script.runInContext (node:vm:149:12)\\n    at runInContext (node:vm:301:6)\\n    at result (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:185:61)\\n    at new Promise (<anonymous>)\\n    at JsTaskRunner.runForAllItems (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:178:34)\\n    at JsTaskRunner.executeTask (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:128:26)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:105:5)",["23"],["24"],["25"],["26"],{"node":"27","data":"28","source":"29"},"webhook",{"startTime":1766125892703,"executionIndex":0,"source":"30","hints":"31","executionTime":0,"executionStatus":"32","data":"33"},{"startTime":1766125892704,"executionIndex":1,"source":"34","hints":"35","executionTime":8,"executionStatus":"32","data":"36"},{"startTime":1766125892713,"executionIndex":2,"source":"37","hints":"38","executionTime":2,"executionStatus":"32","data":"39"},{"startTime":1766125892715,"executionIndex":3,"source":"40","hints":"41","executionTime":5,"executionStatus":"13","error":"42"},{"parameters":"43","id":"44","name":"6","type":"45","typeVersion":2,"position":"46"},{"main":"47"},{"main":"40"},[],[],"success",{"main":"48"},["49"],[],{"main":"50"},["51"],[],{"main":"52"},["53"],[],{"level":"13","tags":"14","description":null,"lineNumber":1,"message":"15","stack":"16"},{"mode":"54","language":"55","jsCode":"56","notice":"57"},"c5bdbcc6-07ac-4ddd-8178-9e0b4514538e","n8n-nodes-base.code",[1216,-16],["58"],["59"],{"previousNode":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},"runOnceForAllItems","javaScript","const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];","",["66"],["67"],"Webhook",["68"],"Extraire Video ID",["69"],[],"Switch",{"json":"70","pairedItem":"71"},{"json":"72","pairedItem":"73"},{"json":"70","pairedItem":"74"},{"json":"70","pairedItem":"75"},{"youtube_url":"76","video_id":"77","use_gemini":true,"timestamp":"78"},{"item":0},{"headers":"79","params":"80","query":"81","body":"82","webhookUrl":"83","executionMode":"84"},{"item":0},{"item":0},{"item":0},"https://www.youtube.com/watch?v=dQw4w9WgXcQ","dQw4w9WgXcQ","2025-12-19T06:31:32.711Z",{"host":"85","user-agent":"86","content-length":"87","content-type":"88","expect":"89","x-forwarded-for":"90","x-forwarded-host":"85","x-forwarded-port":"91","x-forwarded-proto":"92","x-forwarded-server":"93","x-real-ip":"90","accept-encoding":"94"},{},{},{"youtube_url":"76","method":"95"},"http://localhost:5678/webhook/transcribe","production","n8n.chnnlcrypto.cloud","Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7462","79","application/json","100-continue","137.175.221.90","443","https","8dfc70ce64c8","gzip","gemini"]
5	{"id":"ccdNWghInvBMCrnH","name":"Transcription YouTube - Gemini + Whisper","active":true,"activeVersionId":"0b5bec6a-79f9-405b-8566-d059056d3baf","isArchived":false,"createdAt":"2025-12-19T05:51:36.677Z","updatedAt":"2025-12-19T06:26:14.064Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"transcribe","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"1dda2a0a-c0f7-427b-be08-96b16614a399","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[624,96],"webhookId":"transcribe-youtube"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];","notice":""},"id":"9a268a0d-d00a-4545-8e8c-0690806b597a","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[816,96]},{"parameters":{"mode":"rules","rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"ed604210-b9b5-4181-a835-ff7a3ff1742a","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[1024,96]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];","notice":""},"id":"c5bdbcc6-07ac-4ddd-8178-9e0b4514538e","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,-16]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];","notice":""},"id":"8b1394b5-337a-4863-aa2a-6bd952c32df9","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,-16]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","provideSslCertificates":false,"sendQuery":false,"sendHeaders":true,"specifyHeaders":"keypair","headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000},"infoMessage":""},"id":"49309b77-e1a5-4c63-b195-ef783d802f90","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1616,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];","notice":""},"id":"6fe03172-6867-45cf-b044-447c7f8291ea","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1824,-16]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"json","specifyBody":"keypair","bodyParameters":{"parameters":[{"name":"","value":""}]},"options":{"timeout":600000},"infoMessage":""},"id":"06308c22-4095-4e61-a832-9703720d6cbf","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[2016,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"d0a99abf-40a3-46c2-9ee0-23fd8bc94316","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2224,-16]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"847aa2d0-bace-4df8-aec4-91e01b05cf15","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `/home/ne0rignr/.local/bin/ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"b6e1e382-e7e5-42d1-95e7-a7067b6e11b1","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];","notice":""},"id":"4bdc2acd-cf3c-44cd-b19b-65b6d11e4522","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1616,192]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"http://localhost:9000/transcribe","authentication":"none","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"parameterType":"formData","name":"language","value":"fr"}]},"options":{"timeout":3600000},"infoMessage":""},"id":"6e7fd028-5580-42de-8087-eaf19079a765","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1824,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"57c973e5-b369-4d99-9b46-5b8f02549a96","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2016,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"d877c019-82fd-48de-8bec-6471f8328ca9","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[2416,96]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}","notice":""},"id":"7f55a96b-19fe-47f7-9c41-9f3d2ace4446","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[2624,96]},{"parameters":{"enableResponseOutput":false,"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"064bbacf-086b-46c6-9da4-55be014423ce","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[2816,96]}],"connections":{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1","timeSavedMode":"fixed","callerPolicy":"workflowsFromSameOwner","availableInMCP":true},"staticData":{},"pinData":{}}	[{"version":1,"startData":"1","resultData":"2","executionData":"3"},{},{"error":"4","runData":"5","lastNodeExecuted":"6"},{"contextData":"7","nodeExecutionStack":"8","metadata":"9","waitingExecution":"10","waitingExecutionSource":"11","runtimeData":"12"},{"level":"13","tags":"14","description":null,"lineNumber":1,"message":"15","stack":"16"},{"Webhook":"17","Extraire Video ID":"18","Switch":"19","Download Video (Gemini)":"20"},"Download Video (Gemini)",{},["21"],{},{},{},{"version":1,"establishedAt":1766125997021,"source":"22"},"error",{},"Module 'child_process' is disallowed [line 1]","Error: Module 'child_process' is disallowed\\n    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/require-resolver.js:16:27\\n    at VmCodeWrapper (evalmachine.<anonymous>:1:251)\\n    at evalmachine.<anonymous>:16:2\\n    at Script.runInContext (node:vm:149:12)\\n    at runInContext (node:vm:301:6)\\n    at result (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:185:61)\\n    at new Promise (<anonymous>)\\n    at JsTaskRunner.runForAllItems (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:178:34)\\n    at JsTaskRunner.executeTask (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:128:26)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:105:5)",["23"],["24"],["25"],["26"],{"node":"27","data":"28","source":"29"},"webhook",{"startTime":1766125997021,"executionIndex":0,"source":"30","hints":"31","executionTime":0,"executionStatus":"32","data":"33"},{"startTime":1766125997022,"executionIndex":1,"source":"34","hints":"35","executionTime":6,"executionStatus":"32","data":"36"},{"startTime":1766125997028,"executionIndex":2,"source":"37","hints":"38","executionTime":1,"executionStatus":"32","data":"39"},{"startTime":1766125997029,"executionIndex":3,"source":"40","hints":"41","executionTime":4,"executionStatus":"13","error":"42"},{"parameters":"43","id":"44","name":"6","type":"45","typeVersion":2,"position":"46"},{"main":"47"},{"main":"40"},[],[],"success",{"main":"48"},["49"],[],{"main":"50"},["51"],[],{"main":"52"},["53"],[],{"level":"13","tags":"14","description":null,"lineNumber":1,"message":"15","stack":"16"},{"mode":"54","language":"55","jsCode":"56","notice":"57"},"c5bdbcc6-07ac-4ddd-8178-9e0b4514538e","n8n-nodes-base.code",[1216,-16],["58"],["59"],{"previousNode":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},"runOnceForAllItems","javaScript","const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];","",["66"],["67"],"Webhook",["68"],"Extraire Video ID",["69"],[],"Switch",{"json":"70","pairedItem":"71"},{"json":"72","pairedItem":"73"},{"json":"70","pairedItem":"74"},{"json":"70","pairedItem":"75"},{"youtube_url":"76","video_id":"77","use_gemini":true,"timestamp":"78"},{"item":0},{"headers":"79","params":"80","query":"81","body":"82","webhookUrl":"83","executionMode":"84"},{"item":0},{"item":0},{"item":0},"https://www.youtube.com/watch?v=dQw4w9WgXcQ","dQw4w9WgXcQ","2025-12-19T06:33:17.028Z",{"host":"85","user-agent":"86","content-length":"87","content-type":"88","expect":"89","x-forwarded-for":"90","x-forwarded-host":"85","x-forwarded-port":"91","x-forwarded-proto":"92","x-forwarded-server":"93","x-real-ip":"90","accept-encoding":"94"},{},{},{"youtube_url":"76","method":"95"},"http://localhost:5678/webhook/transcribe","production","n8n.chnnlcrypto.cloud","Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7462","79","application/json","100-continue","137.175.221.90","443","https","8dfc70ce64c8","gzip","gemini"]
6	{"id":"ccdNWghInvBMCrnH","name":"Transcription YouTube - Gemini + Whisper","active":true,"activeVersionId":"0b5bec6a-79f9-405b-8566-d059056d3baf","isArchived":false,"createdAt":"2025-12-19T05:51:36.677Z","updatedAt":"2025-12-19T06:26:14.064Z","nodes":[{"parameters":{"multipleMethods":false,"httpMethod":"POST","path":"transcribe","authentication":"none","responseMode":"responseNode","webhookNotice":"","options":{}},"id":"1dda2a0a-c0f7-427b-be08-96b16614a399","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[624,96],"webhookId":"transcribe-youtube"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];","notice":""},"id":"9a268a0d-d00a-4545-8e8c-0690806b597a","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[816,96]},{"parameters":{"mode":"rules","rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"ed604210-b9b5-4181-a835-ff7a3ff1742a","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[1024,96]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];","notice":""},"id":"c5bdbcc6-07ac-4ddd-8178-9e0b4514538e","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,-16]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];","notice":""},"id":"8b1394b5-337a-4863-aa2a-6bd952c32df9","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,-16]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","provideSslCertificates":false,"sendQuery":false,"sendHeaders":true,"specifyHeaders":"keypair","headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000},"infoMessage":""},"id":"49309b77-e1a5-4c63-b195-ef783d802f90","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1616,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];","notice":""},"id":"6fe03172-6867-45cf-b044-447c7f8291ea","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1824,-16]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"json","specifyBody":"keypair","bodyParameters":{"parameters":[{"name":"","value":""}]},"options":{"timeout":600000},"infoMessage":""},"id":"06308c22-4095-4e61-a832-9703720d6cbf","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[2016,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"d0a99abf-40a3-46c2-9ee0-23fd8bc94316","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2224,-16]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"847aa2d0-bace-4df8-aec4-91e01b05cf15","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `/home/ne0rignr/.local/bin/ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];","notice":""},"id":"b6e1e382-e7e5-42d1-95e7-a7067b6e11b1","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];","notice":""},"id":"4bdc2acd-cf3c-44cd-b19b-65b6d11e4522","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1616,192]},{"parameters":{"preBuiltAgentsCalloutHttpRequest":"","curlImport":"","method":"POST","url":"http://localhost:9000/transcribe","authentication":"none","provideSslCertificates":false,"sendQuery":false,"sendHeaders":false,"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"parameterType":"formData","name":"language","value":"fr"}]},"options":{"timeout":3600000},"infoMessage":""},"id":"6e7fd028-5580-42de-8087-eaf19079a765","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1824,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"57c973e5-b369-4d99-9b46-5b8f02549a96","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2016,192]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];","notice":""},"id":"d877c019-82fd-48de-8bec-6471f8328ca9","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[2416,96]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}","notice":""},"id":"7f55a96b-19fe-47f7-9c41-9f3d2ace4446","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[2624,96]},{"parameters":{"enableResponseOutput":false,"generalNotice":"","respondWith":"json","webhookNotice":"","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"064bbacf-086b-46c6-9da4-55be014423ce","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[2816,96]}],"connections":{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}},"settings":{"executionOrder":"v1","timeSavedMode":"fixed","callerPolicy":"workflowsFromSameOwner","availableInMCP":true},"staticData":{},"pinData":{}}	[{"version":1,"startData":"1","resultData":"2","executionData":"3"},{},{"error":"4","runData":"5","lastNodeExecuted":"6"},{"contextData":"7","nodeExecutionStack":"8","metadata":"9","waitingExecution":"10","waitingExecutionSource":"11","runtimeData":"12"},{"level":"13","tags":"14","description":null,"lineNumber":1,"message":"15","stack":"16"},{"Webhook":"17","Extraire Video ID":"18","Switch":"19","Download Video (Gemini)":"20"},"Download Video (Gemini)",{},["21"],{},{},{},{"version":1,"establishedAt":1766126044166,"source":"22"},"error",{},"Module 'child_process' is disallowed [line 1]","Error: Module 'child_process' is disallowed\\n    at /usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/require-resolver.js:16:27\\n    at VmCodeWrapper (evalmachine.<anonymous>:1:251)\\n    at evalmachine.<anonymous>:16:2\\n    at Script.runInContext (node:vm:149:12)\\n    at runInContext (node:vm:301:6)\\n    at result (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:185:61)\\n    at new Promise (<anonymous>)\\n    at JsTaskRunner.runForAllItems (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:178:34)\\n    at JsTaskRunner.executeTask (/usr/local/lib/node_modules/n8n/node_modules/.pnpm/@n8n+task-runner@file+packages+@n8n+task-runner_@opentelemetry+api@1.9.0_@opentelemetry_eb51b38615a039445701c88b088f88d0/node_modules/@n8n/task-runner/dist/js-task-runner/js-task-runner.js:128:26)\\n    at process.processTicksAndRejections (node:internal/process/task_queues:105:5)",["23"],["24"],["25"],["26"],{"node":"27","data":"28","source":"29"},"webhook",{"startTime":1766126044166,"executionIndex":0,"source":"30","hints":"31","executionTime":0,"executionStatus":"32","data":"33"},{"startTime":1766126044166,"executionIndex":1,"source":"34","hints":"35","executionTime":7,"executionStatus":"32","data":"36"},{"startTime":1766126044174,"executionIndex":2,"source":"37","hints":"38","executionTime":1,"executionStatus":"32","data":"39"},{"startTime":1766126044175,"executionIndex":3,"source":"40","hints":"41","executionTime":4,"executionStatus":"13","error":"42"},{"parameters":"43","id":"44","name":"6","type":"45","typeVersion":2,"position":"46"},{"main":"47"},{"main":"40"},[],[],"success",{"main":"48"},["49"],[],{"main":"50"},["51"],[],{"main":"52"},["53"],[],{"level":"13","tags":"14","description":null,"lineNumber":1,"message":"15","stack":"16"},{"mode":"54","language":"55","jsCode":"56","notice":"57"},"c5bdbcc6-07ac-4ddd-8178-9e0b4514538e","n8n-nodes-base.code",[1216,-16],["58"],["59"],{"previousNode":"60"},["61"],{"previousNode":"62"},["63","64"],{"previousNode":"65"},"runOnceForAllItems","javaScript","const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];","",["66"],["67"],"Webhook",["68"],"Extraire Video ID",["69"],[],"Switch",{"json":"70","pairedItem":"71"},{"json":"72","pairedItem":"73"},{"json":"70","pairedItem":"74"},{"json":"70","pairedItem":"75"},{"youtube_url":"76","video_id":"77","use_gemini":true,"timestamp":"78"},{"item":0},{"headers":"79","params":"80","query":"81","body":"82","webhookUrl":"83","executionMode":"84"},{"item":0},{"item":0},{"item":0},"https://www.youtube.com/watch?v=dQw4w9WgXcQ","dQw4w9WgXcQ","2025-12-19T06:34:04.173Z",{"host":"85","user-agent":"86","content-length":"87","content-type":"88","expect":"89","x-forwarded-for":"90","x-forwarded-host":"85","x-forwarded-port":"91","x-forwarded-proto":"92","x-forwarded-server":"93","x-real-ip":"90","accept-encoding":"94"},{},{},{"youtube_url":"76","method":"95"},"http://localhost:5678/webhook/transcribe","production","n8n.chnnlcrypto.cloud","Mozilla/5.0 (Windows NT; Windows NT 10.0; en-US) WindowsPowerShell/5.1.26100.7462","79","application/json","100-continue","137.175.221.90","443","https","8dfc70ce64c8","gzip","gemini"]
\.


--
-- Data for Name: execution_entity; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.execution_entity (id, finished, mode, "retryOf", "retrySuccessId", "startedAt", "stoppedAt", "waitTill", status, "workflowId", "deletedAt", "createdAt") FROM stdin;
1	t	manual	\N	\N	2025-12-18 20:00:53.672+00	2025-12-18 20:00:53.684+00	\N	success	9dwHAWxj9YdjO2Ol	\N	2025-12-18 20:00:53.65+00
2	f	webhook	\N	\N	2025-12-19 05:53:38.627+00	2025-12-19 05:53:38.706+00	\N	error	R31TqM6ks1cBpLkA	\N	2025-12-19 05:53:38.619+00
3	f	webhook	\N	\N	2025-12-19 05:54:05.367+00	2025-12-19 05:54:05.381+00	\N	error	R31TqM6ks1cBpLkA	\N	2025-12-19 05:54:05.361+00
4	f	webhook	\N	\N	2025-12-19 06:31:32.699+00	2025-12-19 06:31:32.721+00	\N	error	ccdNWghInvBMCrnH	\N	2025-12-19 06:31:32.688+00
5	f	webhook	\N	\N	2025-12-19 06:33:17.019+00	2025-12-19 06:33:17.033+00	\N	error	ccdNWghInvBMCrnH	\N	2025-12-19 06:33:17.011+00
6	f	webhook	\N	\N	2025-12-19 06:34:04.164+00	2025-12-19 06:34:04.179+00	\N	error	ccdNWghInvBMCrnH	\N	2025-12-19 06:34:04.156+00
\.


--
-- Data for Name: execution_metadata; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.execution_metadata (id, "executionId", key, value) FROM stdin;
\.


--
-- Data for Name: folder; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.folder (id, name, "parentFolderId", "projectId", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: folder_tag; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.folder_tag ("folderId", "tagId") FROM stdin;
\.


--
-- Data for Name: insights_by_period; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.insights_by_period (id, "metaId", type, value, "periodUnit", "periodStart") FROM stdin;
1	1	1	180	0	2025-12-19 05:00:00+00
3	1	3	4	0	2025-12-19 05:00:00+00
5	2	1	96	0	2025-12-19 06:00:00+00
6	2	3	6	0	2025-12-19 06:00:00+00
\.


--
-- Data for Name: insights_metadata; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.insights_metadata ("metaId", "workflowId", "projectId", "workflowName", "projectName") FROM stdin;
1	R31TqM6ks1cBpLkA	GYUNYABMD2ad4YVi	Transcription YouTube - Gemini + Whisper	Channel Crypto <n8n@chnnlcrypto.cloud>
2	ccdNWghInvBMCrnH	GYUNYABMD2ad4YVi	Transcription YouTube - Gemini + Whisper	Channel Crypto <n8n@chnnlcrypto.cloud>
\.


--
-- Data for Name: insights_raw; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.insights_raw (id, "metaId", type, value, "timestamp") FROM stdin;
\.


--
-- Data for Name: installed_nodes; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.installed_nodes (name, type, "latestVersion", package) FROM stdin;
\.


--
-- Data for Name: installed_packages; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.installed_packages ("packageName", "installedVersion", "authorName", "authorEmail", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: invalid_auth_token; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.invalid_auth_token (token, "expiresAt") FROM stdin;
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.migrations (id, "timestamp", name) FROM stdin;
1	1587669153312	InitialMigration1587669153312
2	1589476000887	WebhookModel1589476000887
3	1594828256133	CreateIndexStoppedAt1594828256133
4	1607431743768	MakeStoppedAtNullable1607431743768
5	1611144599516	AddWebhookId1611144599516
6	1617270242566	CreateTagEntity1617270242566
7	1620824779533	UniqueWorkflowNames1620824779533
8	1626176912946	AddwaitTill1626176912946
9	1630419189837	UpdateWorkflowCredentials1630419189837
10	1644422880309	AddExecutionEntityIndexes1644422880309
11	1646834195327	IncreaseTypeVarcharLimit1646834195327
12	1646992772331	CreateUserManagement1646992772331
13	1648740597343	LowerCaseUserEmail1648740597343
14	1652254514002	CommunityNodes1652254514002
15	1652367743993	AddUserSettings1652367743993
16	1652905585850	AddAPIKeyColumn1652905585850
17	1654090467022	IntroducePinData1654090467022
18	1658932090381	AddNodeIds1658932090381
19	1659902242948	AddJsonKeyPinData1659902242948
20	1660062385367	CreateCredentialsUserRole1660062385367
21	1663755770893	CreateWorkflowsEditorRole1663755770893
22	1664196174001	WorkflowStatistics1664196174001
23	1665484192212	CreateCredentialUsageTable1665484192212
24	1665754637025	RemoveCredentialUsageTable1665754637025
25	1669739707126	AddWorkflowVersionIdColumn1669739707126
26	1669823906995	AddTriggerCountColumn1669823906995
27	1671535397530	MessageEventBusDestinations1671535397530
28	1671726148421	RemoveWorkflowDataLoadedFlag1671726148421
29	1673268682475	DeleteExecutionsWithWorkflows1673268682475
30	1674138566000	AddStatusToExecutions1674138566000
31	1674509946020	CreateLdapEntities1674509946020
32	1675940580449	PurgeInvalidWorkflowConnections1675940580449
33	1676996103000	MigrateExecutionStatus1676996103000
34	1677236854063	UpdateRunningExecutionStatus1677236854063
35	1677501636754	CreateVariables1677501636754
36	1679416281778	CreateExecutionMetadataTable1679416281778
37	1681134145996	AddUserActivatedProperty1681134145996
38	1681134145997	RemoveSkipOwnerSetup1681134145997
39	1690000000000	MigrateIntegerKeysToString1690000000000
40	1690000000020	SeparateExecutionData1690000000020
41	1690000000030	RemoveResetPasswordColumns1690000000030
42	1690000000030	AddMfaColumns1690000000030
43	1690787606731	AddMissingPrimaryKeyOnExecutionData1690787606731
44	1691088862123	CreateWorkflowNameIndex1691088862123
45	1692967111175	CreateWorkflowHistoryTable1692967111175
46	1693491613982	ExecutionSoftDelete1693491613982
47	1693554410387	DisallowOrphanExecutions1693554410387
48	1694091729095	MigrateToTimestampTz1694091729095
49	1695128658538	AddWorkflowMetadata1695128658538
50	1695829275184	ModifyWorkflowHistoryNodesAndConnections1695829275184
51	1700571993961	AddGlobalAdminRole1700571993961
52	1705429061930	DropRoleMapping1705429061930
53	1711018413374	RemoveFailedExecutionStatus1711018413374
54	1711390882123	MoveSshKeysToDatabase1711390882123
55	1712044305787	RemoveNodesAccess1712044305787
56	1714133768519	CreateProject1714133768519
57	1714133768521	MakeExecutionStatusNonNullable1714133768521
58	1717498465931	AddActivatedAtUserSetting1717498465931
59	1720101653148	AddConstraintToExecutionMetadata1720101653148
60	1721377157740	FixExecutionMetadataSequence1721377157740
61	1723627610222	CreateInvalidAuthTokenTable1723627610222
62	1723796243146	RefactorExecutionIndices1723796243146
63	1724753530828	CreateAnnotationTables1724753530828
64	1724951148974	AddApiKeysTable1724951148974
65	1726606152711	CreateProcessedDataTable1726606152711
66	1727427440136	SeparateExecutionCreationFromStart1727427440136
67	1728659839644	AddMissingPrimaryKeyOnAnnotationTagMapping1728659839644
68	1729607673464	UpdateProcessedDataValueColumnToText1729607673464
69	1729607673469	AddProjectIcons1729607673469
70	1730386903556	CreateTestDefinitionTable1730386903556
71	1731404028106	AddDescriptionToTestDefinition1731404028106
72	1731582748663	MigrateTestDefinitionKeyToString1731582748663
73	1732271325258	CreateTestMetricTable1732271325258
74	1732549866705	CreateTestRun1732549866705
75	1733133775640	AddMockedNodesColumnToTestDefinition1733133775640
76	1734479635324	AddManagedColumnToCredentialsTable1734479635324
77	1736172058779	AddStatsColumnsToTestRun1736172058779
78	1736947513045	CreateTestCaseExecutionTable1736947513045
79	1737715421462	AddErrorColumnsToTestRuns1737715421462
80	1738709609940	CreateFolderTable1738709609940
81	1739549398681	CreateAnalyticsTables1739549398681
82	1740445074052	UpdateParentFolderIdColumn1740445074052
83	1741167584277	RenameAnalyticsToInsights1741167584277
84	1742918400000	AddScopesColumnToApiKeys1742918400000
85	1745322634000	ClearEvaluation1745322634000
86	1745587087521	AddWorkflowStatisticsRootCount1745587087521
87	1745934666076	AddWorkflowArchivedColumn1745934666076
88	1745934666077	DropRoleTable1745934666077
89	1747824239000	AddProjectDescriptionColumn1747824239000
90	1750252139166	AddLastActiveAtColumnToUser1750252139166
91	1750252139166	AddScopeTables1750252139166
92	1750252139167	AddRolesTables1750252139167
93	1750252139168	LinkRoleToUserTable1750252139168
94	1750252139170	RemoveOldRoleColumn1750252139170
95	1752669793000	AddInputsOutputsToTestCaseExecution1752669793000
96	1753953244168	LinkRoleToProjectRelationTable1753953244168
97	1754475614601	CreateDataStoreTables1754475614601
98	1754475614602	ReplaceDataStoreTablesWithDataTables1754475614602
99	1756906557570	AddTimestampsToRoleAndRoleIndexes1756906557570
100	1758731786132	AddAudienceColumnToApiKeys1758731786132
101	1758794506893	AddProjectIdToVariableTable1758794506893
102	1759399811000	ChangeValueTypesForInsights1759399811000
103	1760019379982	CreateChatHubTables1760019379982
104	1760020000000	CreateChatHubAgentTable1760020000000
105	1760020838000	UniqueRoleNames1760020838000
106	1760116750277	CreateOAuthEntities1760116750277
107	1760314000000	CreateWorkflowDependencyTable1760314000000
108	1760965142113	DropUnusedChatHubColumns1760965142113
109	1761047826451	AddWorkflowVersionColumn1761047826451
110	1761655473000	ChangeDependencyInfoToJson1761655473000
111	1761773155024	AddAttachmentsToChatHubMessages1761773155024
112	1761830340990	AddToolsColumnToChatHubTables1761830340990
113	1762177736257	AddWorkflowDescriptionColumn1762177736257
114	1762763704614	BackfillMissingWorkflowHistoryRecords1762763704614
115	1762771264000	ChangeDefaultForIdInUserTable1762771264000
116	1762771954619	AddIsGlobalColumnToCredentialsTable1762771954619
117	1762847206508	AddWorkflowHistoryAutoSaveFields1762847206508
118	1763047800000	AddActiveVersionIdColumn1763047800000
119	1763048000000	ActivateExecuteWorkflowTriggerWorkflows1763048000000
120	1763572724000	ChangeOAuthStateColumnToUnboundedVarchar1763572724000
121	1763716655000	CreateBinaryDataTable1763716655000
122	1764167920585	CreateWorkflowPublishHistoryTable1764167920585
123	1765448186933	BackfillMissingWorkflowHistoryRecords1765448186933
\.


--
-- Data for Name: oauth_access_tokens; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.oauth_access_tokens (token, "clientId", "userId") FROM stdin;
\.


--
-- Data for Name: oauth_authorization_codes; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.oauth_authorization_codes (code, "clientId", "userId", "redirectUri", "codeChallenge", "codeChallengeMethod", "expiresAt", state, used, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: oauth_clients; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.oauth_clients (id, name, "redirectUris", "grantTypes", "clientSecret", "clientSecretExpiresAt", "tokenEndpointAuthMethod", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: oauth_refresh_tokens; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.oauth_refresh_tokens (token, "clientId", "userId", "expiresAt", "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: oauth_user_consents; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.oauth_user_consents (id, "userId", "clientId", "grantedAt") FROM stdin;
\.


--
-- Data for Name: processed_data; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.processed_data ("workflowId", context, "createdAt", "updatedAt", value) FROM stdin;
\.


--
-- Data for Name: project; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.project (id, name, type, "createdAt", "updatedAt", icon, description) FROM stdin;
GYUNYABMD2ad4YVi	Channel Crypto <n8n@chnnlcrypto.cloud>	personal	2025-12-18 10:17:42.379+00	2025-12-18 10:24:16.985+00	\N	\N
\.


--
-- Data for Name: project_relation; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.project_relation ("projectId", "userId", role, "createdAt", "updatedAt") FROM stdin;
GYUNYABMD2ad4YVi	6c7170ed-e8fd-4326-af89-3939ab5befbb	project:personalOwner	2025-12-18 10:17:42.379+00	2025-12-18 10:17:42.379+00
\.


--
-- Data for Name: role; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.role (slug, "displayName", description, "roleType", "systemRole", "createdAt", "updatedAt") FROM stdin;
global:owner	Owner	Owner	global	t	2025-12-18 10:17:42.854+00	2025-12-18 10:17:43.089+00
global:admin	Admin	Admin	global	t	2025-12-18 10:17:42.854+00	2025-12-18 10:17:43.089+00
global:member	Member	Member	global	t	2025-12-18 10:17:42.854+00	2025-12-18 10:17:43.089+00
project:admin	Project Admin	Full control of settings, members, workflows, credentials and executions	project	t	2025-12-18 10:17:42.854+00	2025-12-18 10:17:43.108+00
project:personalOwner	Project Owner	Project Owner	project	t	2025-12-18 10:17:42.854+00	2025-12-18 10:17:43.108+00
project:editor	Project Editor	Create, edit, and delete workflows, credentials, and executions	project	t	2025-12-18 10:17:42.854+00	2025-12-18 10:17:43.108+00
project:viewer	Project Viewer	Read-only access to workflows, credentials, and executions	project	t	2025-12-18 10:17:42.854+00	2025-12-18 10:17:43.108+00
credential:owner	Credential Owner	Credential Owner	credential	t	2025-12-18 10:17:43.115+00	2025-12-18 10:17:43.115+00
credential:user	Credential User	Credential User	credential	t	2025-12-18 10:17:43.115+00	2025-12-18 10:17:43.115+00
workflow:owner	Workflow Owner	Workflow Owner	workflow	t	2025-12-18 10:17:43.118+00	2025-12-18 10:17:43.118+00
workflow:editor	Workflow Editor	Workflow Editor	workflow	t	2025-12-18 10:17:43.118+00	2025-12-18 10:17:43.118+00
\.


--
-- Data for Name: role_scope; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.role_scope ("roleSlug", "scopeSlug") FROM stdin;
global:owner	annotationTag:create
global:owner	annotationTag:read
global:owner	annotationTag:update
global:owner	annotationTag:delete
global:owner	annotationTag:list
global:owner	auditLogs:manage
global:owner	banner:dismiss
global:owner	community:register
global:owner	communityPackage:install
global:owner	communityPackage:uninstall
global:owner	communityPackage:update
global:owner	communityPackage:list
global:owner	credential:share
global:owner	credential:shareGlobally
global:owner	credential:move
global:owner	credential:create
global:owner	credential:read
global:owner	credential:update
global:owner	credential:delete
global:owner	credential:list
global:owner	externalSecretsProvider:sync
global:owner	externalSecretsProvider:create
global:owner	externalSecretsProvider:read
global:owner	externalSecretsProvider:update
global:owner	externalSecretsProvider:delete
global:owner	externalSecretsProvider:list
global:owner	externalSecret:list
global:owner	externalSecret:use
global:owner	eventBusDestination:test
global:owner	eventBusDestination:create
global:owner	eventBusDestination:read
global:owner	eventBusDestination:update
global:owner	eventBusDestination:delete
global:owner	eventBusDestination:list
global:owner	ldap:sync
global:owner	ldap:manage
global:owner	license:manage
global:owner	logStreaming:manage
global:owner	orchestration:read
global:owner	project:create
global:owner	project:read
global:owner	project:update
global:owner	project:delete
global:owner	project:list
global:owner	saml:manage
global:owner	securityAudit:generate
global:owner	sourceControl:pull
global:owner	sourceControl:push
global:owner	sourceControl:manage
global:owner	tag:create
global:owner	tag:read
global:owner	tag:update
global:owner	tag:delete
global:owner	tag:list
global:owner	user:resetPassword
global:owner	user:changeRole
global:owner	user:enforceMfa
global:owner	user:create
global:owner	user:read
global:owner	user:update
global:owner	user:delete
global:owner	user:list
global:owner	variable:create
global:owner	variable:read
global:owner	variable:update
global:owner	variable:delete
global:owner	variable:list
global:owner	projectVariable:create
global:owner	projectVariable:read
global:owner	projectVariable:update
global:owner	projectVariable:delete
global:owner	projectVariable:list
global:owner	workersView:manage
global:owner	workflow:share
global:owner	workflow:execute
global:owner	workflow:move
global:owner	workflow:create
global:owner	workflow:read
global:owner	workflow:update
global:owner	workflow:delete
global:owner	workflow:list
global:owner	folder:create
global:owner	folder:read
global:owner	folder:update
global:owner	folder:delete
global:owner	folder:list
global:owner	folder:move
global:owner	insights:list
global:owner	oidc:manage
global:owner	provisioning:manage
global:owner	dataTable:create
global:owner	dataTable:read
global:owner	dataTable:update
global:owner	dataTable:delete
global:owner	dataTable:list
global:owner	dataTable:readRow
global:owner	dataTable:writeRow
global:owner	dataTable:listProject
global:owner	role:manage
global:owner	mcp:manage
global:owner	mcp:oauth
global:owner	mcpApiKey:create
global:owner	mcpApiKey:rotate
global:owner	chatHub:manage
global:owner	chatHub:message
global:owner	chatHubAgent:create
global:owner	chatHubAgent:read
global:owner	chatHubAgent:update
global:owner	chatHubAgent:delete
global:owner	chatHubAgent:list
global:owner	breakingChanges:list
global:admin	annotationTag:create
global:admin	annotationTag:read
global:admin	annotationTag:update
global:admin	annotationTag:delete
global:admin	annotationTag:list
global:admin	auditLogs:manage
global:admin	banner:dismiss
global:admin	community:register
global:admin	communityPackage:install
global:admin	communityPackage:uninstall
global:admin	communityPackage:update
global:admin	communityPackage:list
global:admin	credential:share
global:admin	credential:shareGlobally
global:admin	credential:move
global:admin	credential:create
global:admin	credential:read
global:admin	credential:update
global:admin	credential:delete
global:admin	credential:list
global:admin	externalSecretsProvider:sync
global:admin	externalSecretsProvider:create
global:admin	externalSecretsProvider:read
global:admin	externalSecretsProvider:update
global:admin	externalSecretsProvider:delete
global:admin	externalSecretsProvider:list
global:admin	externalSecret:list
global:admin	externalSecret:use
global:admin	eventBusDestination:test
global:admin	eventBusDestination:create
global:admin	eventBusDestination:read
global:admin	eventBusDestination:update
global:admin	eventBusDestination:delete
global:admin	eventBusDestination:list
global:admin	ldap:sync
global:admin	ldap:manage
global:admin	license:manage
global:admin	logStreaming:manage
global:admin	orchestration:read
global:admin	project:create
global:admin	project:read
global:admin	project:update
global:admin	project:delete
global:admin	project:list
global:admin	saml:manage
global:admin	securityAudit:generate
global:admin	sourceControl:pull
global:admin	sourceControl:push
global:admin	sourceControl:manage
global:admin	tag:create
global:admin	tag:read
global:admin	tag:update
global:admin	tag:delete
global:admin	tag:list
global:admin	user:resetPassword
global:admin	user:changeRole
global:admin	user:enforceMfa
global:admin	user:create
global:admin	user:read
global:admin	user:update
global:admin	user:delete
global:admin	user:list
global:admin	variable:create
global:admin	variable:read
global:admin	variable:update
global:admin	variable:delete
global:admin	variable:list
global:admin	projectVariable:create
global:admin	projectVariable:read
global:admin	projectVariable:update
global:admin	projectVariable:delete
global:admin	projectVariable:list
global:admin	workersView:manage
global:admin	workflow:share
global:admin	workflow:execute
global:admin	workflow:move
global:admin	workflow:create
global:admin	workflow:read
global:admin	workflow:update
global:admin	workflow:delete
global:admin	workflow:list
global:admin	folder:create
global:admin	folder:read
global:admin	folder:update
global:admin	folder:delete
global:admin	folder:list
global:admin	folder:move
global:admin	insights:list
global:admin	oidc:manage
global:admin	provisioning:manage
global:admin	dataTable:create
global:admin	dataTable:read
global:admin	dataTable:update
global:admin	dataTable:delete
global:admin	dataTable:list
global:admin	dataTable:readRow
global:admin	dataTable:writeRow
global:admin	dataTable:listProject
global:admin	role:manage
global:admin	mcp:manage
global:admin	mcp:oauth
global:admin	mcpApiKey:create
global:admin	mcpApiKey:rotate
global:admin	chatHub:manage
global:admin	chatHub:message
global:admin	chatHubAgent:create
global:admin	chatHubAgent:read
global:admin	chatHubAgent:update
global:admin	chatHubAgent:delete
global:admin	chatHubAgent:list
global:admin	breakingChanges:list
global:member	annotationTag:create
global:member	annotationTag:read
global:member	annotationTag:update
global:member	annotationTag:delete
global:member	annotationTag:list
global:member	eventBusDestination:test
global:member	eventBusDestination:list
global:member	tag:create
global:member	tag:read
global:member	tag:update
global:member	tag:list
global:member	user:list
global:member	variable:read
global:member	variable:list
global:member	dataTable:list
global:member	mcp:oauth
global:member	mcpApiKey:create
global:member	mcpApiKey:rotate
global:member	chatHub:message
global:member	chatHubAgent:create
global:member	chatHubAgent:read
global:member	chatHubAgent:update
global:member	chatHubAgent:delete
global:member	chatHubAgent:list
project:admin	credential:share
project:admin	credential:move
project:admin	credential:create
project:admin	credential:read
project:admin	credential:update
project:admin	credential:delete
project:admin	credential:list
project:admin	project:read
project:admin	project:update
project:admin	project:delete
project:admin	project:list
project:admin	sourceControl:push
project:admin	projectVariable:create
project:admin	projectVariable:read
project:admin	projectVariable:update
project:admin	projectVariable:delete
project:admin	projectVariable:list
project:admin	workflow:execute
project:admin	workflow:move
project:admin	workflow:create
project:admin	workflow:read
project:admin	workflow:update
project:admin	workflow:delete
project:admin	workflow:list
project:admin	folder:create
project:admin	folder:read
project:admin	folder:update
project:admin	folder:delete
project:admin	folder:list
project:admin	folder:move
project:admin	dataTable:create
project:admin	dataTable:read
project:admin	dataTable:update
project:admin	dataTable:delete
project:admin	dataTable:readRow
project:admin	dataTable:writeRow
project:admin	dataTable:listProject
project:personalOwner	credential:share
project:personalOwner	credential:move
project:personalOwner	credential:create
project:personalOwner	credential:read
project:personalOwner	credential:update
project:personalOwner	credential:delete
project:personalOwner	credential:list
project:personalOwner	project:read
project:personalOwner	project:list
project:personalOwner	workflow:share
project:personalOwner	workflow:execute
project:personalOwner	workflow:move
project:personalOwner	workflow:create
project:personalOwner	workflow:read
project:personalOwner	workflow:update
project:personalOwner	workflow:delete
project:personalOwner	workflow:list
project:personalOwner	folder:create
project:personalOwner	folder:read
project:personalOwner	folder:update
project:personalOwner	folder:delete
project:personalOwner	folder:list
project:personalOwner	folder:move
project:personalOwner	dataTable:create
project:personalOwner	dataTable:read
project:personalOwner	dataTable:update
project:personalOwner	dataTable:delete
project:personalOwner	dataTable:readRow
project:personalOwner	dataTable:writeRow
project:personalOwner	dataTable:listProject
project:editor	credential:create
project:editor	credential:read
project:editor	credential:update
project:editor	credential:delete
project:editor	credential:list
project:editor	project:read
project:editor	project:list
project:editor	projectVariable:create
project:editor	projectVariable:read
project:editor	projectVariable:update
project:editor	projectVariable:delete
project:editor	projectVariable:list
project:editor	workflow:execute
project:editor	workflow:create
project:editor	workflow:read
project:editor	workflow:update
project:editor	workflow:delete
project:editor	workflow:list
project:editor	folder:create
project:editor	folder:read
project:editor	folder:update
project:editor	folder:delete
project:editor	folder:list
project:editor	dataTable:create
project:editor	dataTable:read
project:editor	dataTable:update
project:editor	dataTable:delete
project:editor	dataTable:readRow
project:editor	dataTable:writeRow
project:editor	dataTable:listProject
project:viewer	credential:read
project:viewer	credential:list
project:viewer	project:read
project:viewer	project:list
project:viewer	projectVariable:read
project:viewer	projectVariable:list
project:viewer	workflow:read
project:viewer	workflow:list
project:viewer	folder:read
project:viewer	folder:list
project:viewer	dataTable:read
project:viewer	dataTable:readRow
project:viewer	dataTable:listProject
credential:owner	credential:share
credential:owner	credential:move
credential:owner	credential:read
credential:owner	credential:update
credential:owner	credential:delete
credential:user	credential:read
workflow:owner	workflow:share
workflow:owner	workflow:execute
workflow:owner	workflow:move
workflow:owner	workflow:read
workflow:owner	workflow:update
workflow:owner	workflow:delete
workflow:editor	workflow:execute
workflow:editor	workflow:read
workflow:editor	workflow:update
\.


--
-- Data for Name: scope; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.scope (slug, "displayName", description) FROM stdin;
annotationTag:create	Create Annotation Tag	Allows creating new annotation tags.
annotationTag:read	annotationTag:read	\N
annotationTag:update	annotationTag:update	\N
annotationTag:delete	annotationTag:delete	\N
annotationTag:list	annotationTag:list	\N
annotationTag:*	annotationTag:*	\N
auditLogs:manage	auditLogs:manage	\N
auditLogs:*	auditLogs:*	\N
banner:dismiss	banner:dismiss	\N
banner:*	banner:*	\N
community:register	community:register	\N
community:*	community:*	\N
communityPackage:install	communityPackage:install	\N
communityPackage:uninstall	communityPackage:uninstall	\N
communityPackage:update	communityPackage:update	\N
communityPackage:list	communityPackage:list	\N
communityPackage:manage	communityPackage:manage	\N
communityPackage:*	communityPackage:*	\N
credential:share	credential:share	\N
credential:shareGlobally	credential:shareGlobally	\N
credential:move	credential:move	\N
credential:create	credential:create	\N
credential:read	credential:read	\N
credential:update	credential:update	\N
credential:delete	credential:delete	\N
credential:list	credential:list	\N
credential:*	credential:*	\N
externalSecretsProvider:sync	externalSecretsProvider:sync	\N
externalSecretsProvider:create	externalSecretsProvider:create	\N
externalSecretsProvider:read	externalSecretsProvider:read	\N
externalSecretsProvider:update	externalSecretsProvider:update	\N
externalSecretsProvider:delete	externalSecretsProvider:delete	\N
externalSecretsProvider:list	externalSecretsProvider:list	\N
externalSecretsProvider:*	externalSecretsProvider:*	\N
externalSecret:list	externalSecret:list	\N
externalSecret:use	externalSecret:use	\N
externalSecret:*	externalSecret:*	\N
eventBusDestination:test	eventBusDestination:test	\N
eventBusDestination:create	eventBusDestination:create	\N
eventBusDestination:read	eventBusDestination:read	\N
eventBusDestination:update	eventBusDestination:update	\N
eventBusDestination:delete	eventBusDestination:delete	\N
eventBusDestination:list	eventBusDestination:list	\N
eventBusDestination:*	eventBusDestination:*	\N
ldap:sync	ldap:sync	\N
ldap:manage	ldap:manage	\N
ldap:*	ldap:*	\N
license:manage	license:manage	\N
license:*	license:*	\N
logStreaming:manage	logStreaming:manage	\N
logStreaming:*	logStreaming:*	\N
orchestration:read	orchestration:read	\N
orchestration:list	orchestration:list	\N
orchestration:*	orchestration:*	\N
project:create	project:create	\N
project:read	project:read	\N
project:update	project:update	\N
project:delete	project:delete	\N
project:list	project:list	\N
project:*	project:*	\N
saml:manage	saml:manage	\N
saml:*	saml:*	\N
securityAudit:generate	securityAudit:generate	\N
securityAudit:*	securityAudit:*	\N
sourceControl:pull	sourceControl:pull	\N
sourceControl:push	sourceControl:push	\N
sourceControl:manage	sourceControl:manage	\N
sourceControl:*	sourceControl:*	\N
tag:create	tag:create	\N
tag:read	tag:read	\N
tag:update	tag:update	\N
tag:delete	tag:delete	\N
tag:list	tag:list	\N
tag:*	tag:*	\N
user:resetPassword	user:resetPassword	\N
user:changeRole	user:changeRole	\N
user:enforceMfa	user:enforceMfa	\N
user:create	user:create	\N
user:read	user:read	\N
user:update	user:update	\N
user:delete	user:delete	\N
user:list	user:list	\N
user:*	user:*	\N
variable:create	variable:create	\N
variable:read	variable:read	\N
variable:update	variable:update	\N
variable:delete	variable:delete	\N
variable:list	variable:list	\N
variable:*	variable:*	\N
projectVariable:create	projectVariable:create	\N
projectVariable:read	projectVariable:read	\N
projectVariable:update	projectVariable:update	\N
projectVariable:delete	projectVariable:delete	\N
projectVariable:list	projectVariable:list	\N
projectVariable:*	projectVariable:*	\N
workersView:manage	workersView:manage	\N
workersView:*	workersView:*	\N
workflow:share	workflow:share	\N
workflow:execute	workflow:execute	\N
workflow:move	workflow:move	\N
workflow:activate	workflow:activate	\N
workflow:deactivate	workflow:deactivate	\N
workflow:create	workflow:create	\N
workflow:read	workflow:read	\N
workflow:update	workflow:update	\N
workflow:delete	workflow:delete	\N
workflow:list	workflow:list	\N
workflow:*	workflow:*	\N
folder:create	folder:create	\N
folder:read	folder:read	\N
folder:update	folder:update	\N
folder:delete	folder:delete	\N
folder:list	folder:list	\N
folder:move	folder:move	\N
folder:*	folder:*	\N
insights:list	insights:list	\N
insights:*	insights:*	\N
oidc:manage	oidc:manage	\N
oidc:*	oidc:*	\N
provisioning:manage	provisioning:manage	\N
provisioning:*	provisioning:*	\N
dataTable:create	dataTable:create	\N
dataTable:read	dataTable:read	\N
dataTable:update	dataTable:update	\N
dataTable:delete	dataTable:delete	\N
dataTable:list	dataTable:list	\N
dataTable:readRow	dataTable:readRow	\N
dataTable:writeRow	dataTable:writeRow	\N
dataTable:listProject	dataTable:listProject	\N
dataTable:*	dataTable:*	\N
execution:delete	execution:delete	\N
execution:read	execution:read	\N
execution:retry	execution:retry	\N
execution:list	execution:list	\N
execution:get	execution:get	\N
execution:*	execution:*	\N
workflowTags:update	workflowTags:update	\N
workflowTags:list	workflowTags:list	\N
workflowTags:*	workflowTags:*	\N
role:manage	role:manage	\N
role:*	role:*	\N
mcp:manage	mcp:manage	\N
mcp:oauth	mcp:oauth	\N
mcp:*	mcp:*	\N
mcpApiKey:create	mcpApiKey:create	\N
mcpApiKey:rotate	mcpApiKey:rotate	\N
mcpApiKey:*	mcpApiKey:*	\N
chatHub:manage	chatHub:manage	\N
chatHub:message	chatHub:message	\N
chatHub:*	chatHub:*	\N
chatHubAgent:create	chatHubAgent:create	\N
chatHubAgent:read	chatHubAgent:read	\N
chatHubAgent:update	chatHubAgent:update	\N
chatHubAgent:delete	chatHubAgent:delete	\N
chatHubAgent:list	chatHubAgent:list	\N
chatHubAgent:*	chatHubAgent:*	\N
breakingChanges:list	breakingChanges:list	\N
breakingChanges:*	breakingChanges:*	\N
*	*	\N
\.


--
-- Data for Name: settings; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.settings (key, value, "loadOnStartup") FROM stdin;
ui.banners.dismissed	["V1"]	t
features.ldap	{"loginEnabled":false,"loginLabel":"","connectionUrl":"","allowUnauthorizedCerts":false,"connectionSecurity":"none","connectionPort":389,"baseDn":"","bindingAdminDn":"","bindingAdminPassword":"","firstNameAttribute":"","lastNameAttribute":"","emailAttribute":"","loginIdAttribute":"","ldapIdAttribute":"","userFilter":"","synchronizationEnabled":false,"synchronizationInterval":60,"searchPageSize":0,"searchTimeout":60,"enforceEmailUniqueness":true}	t
userManagement.authenticationMethod	email	t
features.sourceControl.sshKeys	{"encryptedPrivateKey":"U2FsdGVkX1/mNKPVa0p9ryl8Z8MZwjdFIGIRYkKiTY5vYuW6+j4Jb+5vwJ/EyOA6GihEQxvkLeuP2ToLoOor0NACxMasMvi7PY5kYh3HAjCW3xZMd0KNvNu8bXD8f3IerfQZv7+i0n8ZT1wI02kVPXWhwTu/tTLnghvoSj7WET8IxtLSBfBFB3fvt5gq5mB3NPcFSPWjhafB5KwHzWYe9KBnz4IEJWkbHX4ELj2hpHzEjQiQfF0l1JKrQL6LF+C95Jah8VzAkfkDXdhOwDoEWWJr77i7IoV/Inmkd48tb/tNbk5/sJEyAZ2cg2rvGHkZnBQip91vIwWSh/Yw6dywCvRZy6kRhbyVZUH2wetISH0Idj5kPfpqIfhgcXps8v3S7pqgs1B566knemczPgR3W0NdA7D56WHf5S0muqJ3Ksrmh7yS51pSfpL31w4oCW1dQzp2Aj8f/CZMELyY+GlVW0C9pO6zHl2SHecYiFW4PZz0YNd57ak69aSVr1x2K5t0uG1RwN5Xv1IuvWUsCyNYRGLxjoUGFW3qjv5JQmaF2VYPOzbpB2dgnaFxhEBMKJAs","publicKey":"ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGsfOr3HfixoYB/gOiqxgLa68sDA/TC3JWRqYFEiBS/I n8n deploy key"}	t
features.sourceControl	{"branchName":"main","connectionType":"ssh","keyGeneratorType":"ed25519"}	t
userManagement.isInstanceOwnerSetUp	true	t
mcp.access.enabled	true	t
\.


--
-- Data for Name: shared_credentials; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.shared_credentials ("credentialsId", "projectId", role, "createdAt", "updatedAt") FROM stdin;
I3D538Occ66Sb5YV	GYUNYABMD2ad4YVi	credential:owner	2025-12-18 19:38:04.89+00	2025-12-18 19:38:04.89+00
\.


--
-- Data for Name: shared_workflow; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.shared_workflow ("workflowId", "projectId", role, "createdAt", "updatedAt") FROM stdin;
9dwHAWxj9YdjO2Ol	GYUNYABMD2ad4YVi	workflow:owner	2025-12-18 10:38:27.203+00	2025-12-18 10:38:27.203+00
UzLhODuCRP8ffkct	GYUNYABMD2ad4YVi	workflow:owner	2025-12-19 03:58:03.089+00	2025-12-19 03:58:03.089+00
R31TqM6ks1cBpLkA	GYUNYABMD2ad4YVi	workflow:owner	2025-12-19 03:58:17.115+00	2025-12-19 03:58:17.115+00
ccdNWghInvBMCrnH	GYUNYABMD2ad4YVi	workflow:owner	2025-12-19 05:51:36.677+00	2025-12-19 05:51:36.677+00
nAA8iukS0ukDaeqK	GYUNYABMD2ad4YVi	workflow:owner	2025-12-19 07:47:22.002+00	2025-12-19 07:47:22.002+00
\.


--
-- Data for Name: tag_entity; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.tag_entity (name, "createdAt", "updatedAt", id) FROM stdin;
\.


--
-- Data for Name: test_case_execution; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.test_case_execution (id, "testRunId", "executionId", status, "runAt", "completedAt", "errorCode", "errorDetails", metrics, "createdAt", "updatedAt", inputs, outputs) FROM stdin;
\.


--
-- Data for Name: test_run; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.test_run (id, "workflowId", status, "errorCode", "errorDetails", "runAt", "completedAt", metrics, "createdAt", "updatedAt") FROM stdin;
\.


--
-- Data for Name: user; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public."user" (id, email, "firstName", "lastName", password, "personalizationAnswers", "createdAt", "updatedAt", settings, disabled, "mfaEnabled", "mfaSecret", "mfaRecoveryCodes", "lastActiveAt", "roleSlug") FROM stdin;
6c7170ed-e8fd-4326-af89-3939ab5befbb	n8n@chnnlcrypto.cloud	Channel	Crypto	$2a$10$ACbBaLrfYqNmRnUnJDZVkui3AanXPW1y60YsIw4ESe1AaWwVPIVC2	{"version":"v4","personalization_survey_submitted_at":"2025-12-18T10:24:43.710Z","personalization_survey_n8n_version":"2.0.3","companySize":"<20","companyType":"saas","role":"business-owner","reportedSource":"youtube"}	2025-12-18 10:17:41.934+00	2025-12-19 07:56:13.232+00	{"userActivated": false}	f	f	\N	\N	2025-12-19	global:owner
\.


--
-- Data for Name: user_api_keys; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.user_api_keys (id, "userId", label, "apiKey", "createdAt", "updatedAt", scopes, audience) FROM stdin;
rmXH66tlIKj13gvf	6c7170ed-e8fd-4326-af89-3939ab5befbb	n8n Claude - vs-code(mcp)	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YzcxNzBlZC1lOGZkLTQzMjYtYWY4OS0zOTM5YWI1YmVmYmIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY2MDUzNjYwfQ.skHm5mSo4yukPwnF3MoFH96uUQPn-otoNLH2NobAoLY	2025-12-18 10:27:40.146+00	2025-12-18 10:27:40.146+00	["credential:move","credential:create","credential:delete","project:create","project:update","project:delete","project:list","securityAudit:generate","sourceControl:pull","tag:create","tag:read","tag:update","tag:delete","tag:list","user:changeRole","user:enforceMfa","user:create","user:read","user:delete","user:list","variable:create","variable:update","variable:delete","variable:list","workflow:move","workflow:create","workflow:read","workflow:update","workflow:delete","workflow:list","workflowTags:update","workflowTags:list","workflow:activate","workflow:deactivate","execution:delete","execution:read","execution:retry","execution:list"]	public-api
TbfKXduf81eUf0ID	6c7170ed-e8fd-4326-af89-3939ab5befbb	MCP Server API Key	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YzcxNzBlZC1lOGZkLTQzMjYtYWY4OS0zOTM5YWI1YmVmYmIiLCJpc3MiOiJuOG4iLCJhdWQiOiJtY3Atc2VydmVyLWFwaSIsImp0aSI6IjAxNGQ5M2ExLWIyZmItNGQ0Yi1iZTg1LTE5ZDNlMGVmOTlhOCIsImlhdCI6MTc2NjA4NzEwN30.GbRcJXfw6G_CBqZpyUGQz3ZEDGIC0lMieDheWnEon1Q	2025-12-18 19:45:07.523+00	2025-12-18 19:45:07.523+00	[]	mcp-server-api
ZVKawrFnOozt1V6P	6c7170ed-e8fd-4326-af89-3939ab5befbb	import n8n - vs code	eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiI2YzcxNzBlZC1lOGZkLTQzMjYtYWY4OS0zOTM5YWI1YmVmYmIiLCJpc3MiOiJuOG4iLCJhdWQiOiJwdWJsaWMtYXBpIiwiaWF0IjoxNzY2MTE0NzE5fQ.MJtR36bxBa4sWRe31fFJLe9w3i44Kw5HFE5knCOi7bg	2025-12-19 03:25:19.652+00	2025-12-19 03:25:19.652+00	["credential:move","credential:create","credential:delete","project:create","project:update","project:delete","project:list","securityAudit:generate","sourceControl:pull","tag:create","tag:read","tag:update","tag:delete","tag:list","user:changeRole","user:enforceMfa","user:create","user:read","user:delete","user:list","variable:create","variable:update","variable:delete","variable:list","workflow:move","workflow:create","workflow:read","workflow:update","workflow:delete","workflow:list","workflowTags:update","workflowTags:list","workflow:activate","workflow:deactivate","execution:delete","execution:read","execution:retry","execution:list"]	public-api
\.


--
-- Data for Name: variables; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.variables (key, type, value, id, "projectId") FROM stdin;
\.


--
-- Data for Name: webhook_entity; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.webhook_entity ("webhookPath", method, node, "webhookId", "pathLength", "workflowId") FROM stdin;
\.


--
-- Data for Name: workflow_dependency; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.workflow_dependency (id, "workflowId", "workflowVersionId", "dependencyType", "dependencyKey", "dependencyInfo", "indexVersionId", "createdAt") FROM stdin;
\.


--
-- Data for Name: workflow_entity; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.workflow_entity (name, active, nodes, connections, "createdAt", "updatedAt", settings, "staticData", "pinData", "versionId", "triggerCount", id, meta, "parentFolderId", "isArchived", "versionCounter", description, "activeVersionId") FROM stdin;
Transcription YouTube - Gemini + Whisper	f	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"webhook-001","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,400],"webhookId":"transcribe-youtube"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"extract-id-001","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,400]},{"parameters":{"mode":"rules","rules":{"values":[{"outputKey":"Gemini","conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true},{"outputKey":"Whisper","conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true}]},"options":{}},"id":"switch-001","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[650,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"download-gemini-001","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,300]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{"name":"contents","value":"={{ [{\\"parts\\": [{\\"text\\": \\"Transcris cette vidéo en français. Retourne uniquement le texte de la transcription, sans aucun formatage ni commentaire.\\"}, {\\"fileData\\": {\\"mimeType\\": \\"video/mp4\\", \\"fileUri\\": \\"gs://temp-bucket/\\" + $json.video_id + \\".mp4\\"}}]}] }}"}]},"options":{"timeout":300000}},"id":"gemini-api-001","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1050,300],"credentials":{"httpQueryAuth":{"id":"gemini-api-key","name":"Gemini API Key"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Download Video (Gemini)').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"parse-gemini-001","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,300]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"download-whisper-001","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"extract-audio-001","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1050,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"read-audio-001","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,500]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"name":"file","inputDataFieldName":"data","parameterType":"formBinaryData"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"whisper-api-001","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1450,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"parse-whisper-001","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"save-files-001","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1450,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"cleanup-001","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,400]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"response-001","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1850,400]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}}	2025-12-19 03:58:03.089+00	2025-12-19 03:58:03.089+00	{"executionOrder":"v1","callerPolicy":"workflowsFromSameOwner","availableInMCP":false}	\N	\N	a74c79d0-284c-4d35-acd8-46fe2ac4489a	0	UzLhODuCRP8ffkct	\N	\N	f	1	\N	\N
Transcription YouTube - Gemini + Whisper	f	[{"parameters":{"rules":{"values":[{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":1},"conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}","id":"1deba6d9-96d6-4b10-9b2c-cc88230e573d"}],"combinator":"and"},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":1},"conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}","id":"3face287-9a3b-415f-9297-91447916b6de"}],"combinator":"and"},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"21749132-c2af-4323-b1dc-645b7238c503","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[544,448]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"45292cee-20dc-483d-abeb-0400c00c6b22","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[736,336]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{"name":"contents","value":"={{ [{\\"parts\\": [{\\"text\\": \\"Transcris cette vidéo en français. Retourne uniquement le texte de la transcription, sans aucun formatage ni commentaire.\\"}, {\\"fileData\\": {\\"mimeType\\": \\"video/mp4\\", \\"fileUri\\": \\"gs://temp-bucket/\\" + $json.video_id + \\".mp4\\"}}]}] }}"}]},"options":{"timeout":300000}},"id":"299dc582-ec89-498a-a1aa-9f9ceb74cc90","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[944,336],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Download Video (Gemini)').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"8627e11e-1e32-4985-b645-da1491cb50ca","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1136,336]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"d2a966b3-2197-468e-8ef4-affc8c1952f7","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[736,544]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"1d9c94a0-1779-4262-8499-0d54f1b6dfdd","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[944,544]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"ba87a30b-feaa-4d5e-8bb5-41b51436f4da","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1136,544]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"2b608ad9-67af-4905-a2ff-7d613b7b67fe","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1344,544]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"4cd1054d-67e3-44ed-bc51-c595d5700a80","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1536,544]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID1').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"8b44c4e3-6d59-4476-926e-23518679def1","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1344,448]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"4c62182f-e3bb-47cc-8efa-dbf977221895","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1536,448]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"d4816c4b-8059-484a-b6d2-9b0fe1ff9e5c","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1744,448]},{"parameters":{"jsCode":"const body = $input.first().json.body;\\nconst youtubeUrl = body.youtube_url || body.url;\\nconst useGemini = body.use_gemini !== false;\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"4520f0bf-1111-42b1-8b7a-edf80f22d185","name":"Extraire Video ID1","type":"n8n-nodes-base.code","typeVersion":2,"position":[336,448]},{"parameters":{"formTitle":"Transcription YouTube","formDescription":"https://www.youtube.com/watch?v=suy4wc-t0kg","formFields":{"values":[{"fieldLabel":"youtube_url","placeholder":"https://www.youtube.com/watch?v=","requiredField":true},{"fieldLabel":"method","fieldType":"checkbox","fieldOptions":{"values":[{"option":"gemini"},{"option":"whisper"}]},"limitSelection":"exact","requiredField":true}]},"options":{}},"type":"n8n-nodes-base.formTrigger","typeVersion":2.3,"position":[112,448],"id":"41d0bede-58ea-4bec-a9a4-c63b458f4c62","name":"On form submission","webhookId":"a5a8a84a-97ba-4d04-aced-e35ff478dc5b"}]	{"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]},"Extraire Video ID1":{"main":[[{"node":"Switch","type":"main","index":0}]]},"On form submission":{"main":[[{"node":"Extraire Video ID1","type":"main","index":0}]]}}	2025-12-18 10:38:27.203+00	2025-12-19 05:57:58.171+00	{"executionOrder":"v1","timeSavedMode":"fixed","callerPolicy":"workflowsFromSameOwner","availableInMCP":false}	\N	{}	b4a67768-ecdc-4e3d-a46a-c834082b3f93	1	9dwHAWxj9YdjO2Ol	\N	\N	f	45	\N	\N
Transcription YouTube - Gemini + Whisper	f	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"webhook-001","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,400],"webhookId":"transcribe-youtube"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"extract-id-001","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,400]},{"parameters":{"mode":"rules","rules":{"values":[{"outputKey":"Gemini","conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true},{"outputKey":"Whisper","conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true}]},"options":{}},"id":"switch-001","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[650,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"download-gemini-001","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,300]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{"name":"contents","value":"={{ [{\\"parts\\": [{\\"text\\": \\"Transcris cette vidéo en français. Retourne uniquement le texte de la transcription, sans aucun formatage ni commentaire.\\"}, {\\"fileData\\": {\\"mimeType\\": \\"video/mp4\\", \\"fileUri\\": \\"gs://temp-bucket/\\" + $json.video_id + \\".mp4\\"}}]}] }}"}]},"options":{"timeout":300000}},"id":"gemini-api-001","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1050,300],"credentials":{"httpQueryAuth":{"id":"gemini-api-key","name":"Gemini API Key"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Download Video (Gemini)').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"parse-gemini-001","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,300]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"download-whisper-001","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"extract-audio-001","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1050,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"read-audio-001","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,500]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"name":"file","inputDataFieldName":"data","parameterType":"formBinaryData"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"whisper-api-001","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1450,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"parse-whisper-001","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"save-files-001","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1450,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"cleanup-001","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,400]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"response-001","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1850,400]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}}	2025-12-19 03:58:17.115+00	2025-12-19 05:57:41.995+00	{"executionOrder":"v1","callerPolicy":"workflowsFromSameOwner","availableInMCP":false,"timeSavedMode":"fixed"}	\N	\N	58f1c494-b128-48b8-b0b9-e1102ca79c0b	1	R31TqM6ks1cBpLkA	\N	\N	f	13	\N	\N
Transcription YouTube - Gemini + Whisper	f	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"b0db5c3d-b916-4c37-b087-776533709d86","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-624,128],"webhookId":"transcribe-youtube"},{"parameters":{"jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"f98e78c6-5f46-4323-a8af-64338cc55703","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[-416,144]},{"parameters":{"rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"ebbaf736-0ca3-4f92-91ea-c6df00fda78d","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[-224,144]},{"parameters":{},"id":"ecbefe89-e866-4e80-b5c8-c0e8f2a7337b","name":"Download Video (Gemini)","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[-48,-16]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Extraire Video ID').item.json.video_id }}","type":"string"},{"id":"youtube_url","name":"youtube_url","value":"={{ $('Extraire Video ID').item.json.youtube_url }}","type":"string"},{"id":"video_path","name":"video_path","value":"=/tmp/{{ $('Extraire Video ID').item.json.video_id }}.mp4","type":"string"},{"id":"method","name":"method","value":"gemini","type":"string"}]},"options":{}},"id":"32c2c47f-3539-40be-a5e6-9c7a4e036ade","name":"Set Gemini Data","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[80,-32]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];"},"id":"315f70f7-4271-4125-a231-df559c55aad9","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[272,-64]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000}},"id":"cb7d8b46-b3a1-4819-8c52-4bdf48759f4d","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[448,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];"},"id":"10f808b6-2cbc-4a1e-8b2c-87548f4d1fb1","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[640,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{"timeout":600000}},"id":"c0ac21c8-2d2d-4d01-b994-55b6f550b73d","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[832,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"8d391bd8-35cf-4924-92eb-77fc28d3c6f2","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1008,0]},{"parameters":{},"id":"a468e76b-d713-4af4-9746-dbfeb27cf840","name":"Download Video (Whisper)","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[-96,288]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Extraire Video ID').item.json.video_id }}","type":"string"},{"id":"youtube_url","name":"youtube_url","value":"={{ $('Extraire Video ID').item.json.youtube_url }}","type":"string"},{"id":"video_path","name":"video_path","value":"=/tmp/{{ $('Extraire Video ID').item.json.video_id }}.mp4","type":"string"},{"id":"method","name":"method","value":"whisper","type":"string"}]},"options":{}},"id":"2b04f062-65c4-4b77-8d43-de5fa9726794","name":"Set Whisper Data","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[48,288]},{"parameters":{},"id":"9ffd9cd8-9e48-4f51-b563-b24cc92f0e8a","name":"Extract Audio","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[224,288]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Set Whisper Data').item.json.video_id }}","type":"string"},{"id":"audio_path","name":"audio_path","value":"=/tmp/{{ $('Set Whisper Data').item.json.video_id }}.mp3","type":"string"},{"id":"method","name":"method","value":"whisper","type":"string"}]},"options":{}},"id":"23121148-c1b4-4bf8-b14f-c727cd9315df","name":"Set Audio Data","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[352,288]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"a5cd0e1c-8605-463a-ba64-9a9e35916254","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[512,256]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"2a49b346-64f7-4e43-aadc-b6d8ab5edc2b","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[704,256]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"c521435b-30a2-4b24-9a6f-c724d3304d96","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[896,208]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"fe6e299a-7e67-4758-af23-6f6f1a7ad4ab","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1200,112]},{"parameters":{},"id":"e51e8c15-b1e2-4511-a5bf-cd56f07a19fa","name":"Cleanup","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[1344,112]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Save Files').item.json.video_id }}","type":"string"},{"id":"method","name":"method","value":"={{ $('Save Files').item.json.method }}","type":"string"},{"id":"output_dir","name":"output_dir","value":"={{ $('Save Files').item.json.output_dir }}","type":"string"},{"id":"text_length","name":"text_length","value":"={{ $('Save Files').item.json.text_length }}","type":"number"},{"id":"cleanup_success","name":"cleanup_success","value":true,"type":"boolean"}]},"options":{}},"id":"0f2e0c8a-3688-4d49-8b62-9679bc838788","name":"Set Cleanup Result","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[1520,112]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"433215d8-1bcb-4318-8dfc-cfd5214ecf5d","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1664,112]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Set Gemini Data":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Set Audio Data":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Set Cleanup Result":{"main":[[{"node":"Response","type":"main","index":0}]]}}	2025-12-19 07:47:22.002+00	2025-12-19 08:18:29.665+00	{"executionOrder":"v1"}	\N	{}	b3429838-5dbc-431e-a95e-eb750b9a20b1	0	nAA8iukS0ukDaeqK	\N	\N	t	6	\N	\N
Transcription YouTube - Gemini + Whisper	f	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"1dda2a0a-c0f7-427b-be08-96b16614a399","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[624,96],"webhookId":"transcribe-youtube"},{"parameters":{"jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"9a268a0d-d00a-4545-8e8c-0690806b597a","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[816,96]},{"parameters":{"rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"ed604210-b9b5-4181-a835-ff7a3ff1742a","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[1024,96]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"c5bdbcc6-07ac-4ddd-8178-9e0b4514538e","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,-16]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];"},"id":"8b1394b5-337a-4863-aa2a-6bd952c32df9","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000}},"id":"49309b77-e1a5-4c63-b195-ef783d802f90","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1616,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];"},"id":"6fe03172-6867-45cf-b044-447c7f8291ea","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1824,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{"timeout":600000}},"id":"06308c22-4095-4e61-a832-9703720d6cbf","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[2016,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"d0a99abf-40a3-46c2-9ee0-23fd8bc94316","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2224,-16]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"847aa2d0-bace-4df8-aec4-91e01b05cf15","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,192]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `/home/ne0rignr/.local/bin/ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"b6e1e382-e7e5-42d1-95e7-a7067b6e11b1","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,192]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"4bdc2acd-cf3c-44cd-b19b-65b6d11e4522","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1616,192]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"6e7fd028-5580-42de-8087-eaf19079a765","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1824,192]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"57c973e5-b369-4d99-9b46-5b8f02549a96","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2016,192]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"d877c019-82fd-48de-8bec-6471f8328ca9","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[2416,96]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"7f55a96b-19fe-47f7-9c41-9f3d2ace4446","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[2624,96]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"064bbacf-086b-46c6-9da4-55be014423ce","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[2816,96]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}}	2025-12-19 05:51:36.677+00	2025-12-19 07:05:04.449+00	{"executionOrder":"v1","timeSavedMode":"fixed","callerPolicy":"workflowsFromSameOwner","availableInMCP":false}	\N	{}	0b5bec6a-79f9-405b-8566-d059056d3baf	1	ccdNWghInvBMCrnH	\N	\N	f	15	\N	\N
\.


--
-- Data for Name: workflow_history; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.workflow_history ("versionId", "workflowId", authors, "createdAt", "updatedAt", nodes, connections, name, autosaved, description) FROM stdin;
59ae416c-d816-4b17-80cf-ec09fc2dce8c	9dwHAWxj9YdjO2Ol	Channel Crypto	2025-12-18 10:38:27.203+00	2025-12-18 10:38:27.203+00	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[0,0],"id":"5a7daead-37f3-4f75-a44f-3be4ed333899","webhookId":"71a0a600-e31a-4e37-b7a6-91265ec31436"},{"parameters":{"jsCode":"const body = $input.item.json.body || $input.item.json;\\nconst url = body.youtube_url;\\nif (!url) throw new Error('youtube_url manquante');\\nconst match = url.match(/[?&]v=([^&]+)/);\\nif (!match) throw new Error('URL invalide');\\nreturn { json: { youtube_url: url, video_id: match[1], timestamp: new Date().toISOString() } };"},"name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[208,0],"id":"a299d969-2375-44d9-adbe-c09039f728fb"},{"parameters":{},"name":"Telecharger Video","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[400,0],"id":"dd0d861a-8043-42d1-8ba2-5b5622718a46"},{"parameters":{},"name":"Extraire Audio","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[608,0],"id":"443a59a6-53b6-4f6a-ae22-1cc9ac722d98"},{"parameters":{"filePath":"=/tmp/{{ $('Extraire Video ID').item.json.video_id }}.mp3"},"name":"Lire Audio","type":"n8n-nodes-base.readBinaryFile","typeVersion":1,"position":[800,0],"id":"b35fb162-4d37-484b-a2ca-5b832b421624"},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"n8nBinaryData","name":"file"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"name":"Transcrire Whisper","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1008,0],"id":"aa813a19-cea7-4d34-8e31-8a4e95a6434e"},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\nconst response = $input.item.json;\\nconst videoId = $('Extraire Video ID').item.json.video_id;\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\nfs.mkdirSync(outputDir, { recursive: true });\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, response.text, 'utf8');\\nconst metadata = {\\n  video_id: videoId,\\n  method: 'whisper-local',\\n  model: 'whisper-medium',\\n  language: response.language,\\n  duration: response.duration,\\n  text_length: response.text.length,\\n  timestamp: new Date().toISOString(),\\n  youtube_url: $('Extraire Video ID').item.json.youtube_url\\n};\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2), 'utf8');\\nreturn {\\n  json: {\\n    success: true,\\n    video_id: videoId,\\n    output_dir: outputDir,\\n    transcription_file: transcriptionPath,\\n    metadata_file: metadataPath,\\n    text_length: response.text.length\\n  }\\n};"},"name":"Sauvegarder Fichiers","type":"n8n-nodes-base.code","typeVersion":2,"position":[1200,0],"id":"971b19b5-d750-42a4-a82c-c5b8a22e89c6"},{"parameters":{},"name":"Nettoyer Fichiers Temp","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[1408,0],"id":"a2d95ca4-5eef-415c-a26b-7513ab6718fb"},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  success: true,\\n  message: 'Transcription terminee',\\n  video_id: $json.video_id,\\n  output_directory: $json.output_dir,\\n  text_length: $json.text_length\\n} }}","options":{}},"name":"Repondre Webhook","type":"n8n-nodes-base.respondToWebhook","typeVersion":1,"position":[1600,0],"id":"e599f8cd-ba60-4168-84b5-2a4df5803f0f"}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Lire Audio":{"main":[[{"node":"Transcrire Whisper","type":"main","index":0}]]},"Transcrire Whisper":{"main":[[{"node":"Sauvegarder Fichiers","type":"main","index":0}]]}}	\N	f	\N
1c564b71-19f5-413a-ad06-14d84d823206	9dwHAWxj9YdjO2Ol	Channel Crypto	2025-12-18 19:40:14.207+00	2025-12-18 19:49:54.127+00	[{"parameters":{"rules":{"values":[{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":1},"conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}","id":"1deba6d9-96d6-4b10-9b2c-cc88230e573d"}],"combinator":"and"},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":1},"conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}","id":"3face287-9a3b-415f-9297-91447916b6de"}],"combinator":"and"},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"21749132-c2af-4323-b1dc-645b7238c503","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[544,448]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"45292cee-20dc-483d-abeb-0400c00c6b22","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[736,336]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{"name":"contents","value":"={{ [{\\"parts\\": [{\\"text\\": \\"Transcris cette vidéo en français. Retourne uniquement le texte de la transcription, sans aucun formatage ni commentaire.\\"}, {\\"fileData\\": {\\"mimeType\\": \\"video/mp4\\", \\"fileUri\\": \\"gs://temp-bucket/\\" + $json.video_id + \\".mp4\\"}}]}] }}"}]},"options":{"timeout":300000}},"id":"299dc582-ec89-498a-a1aa-9f9ceb74cc90","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[944,336],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Download Video (Gemini)').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"8627e11e-1e32-4985-b645-da1491cb50ca","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1136,336]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"d2a966b3-2197-468e-8ef4-affc8c1952f7","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[736,544]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"1d9c94a0-1779-4262-8499-0d54f1b6dfdd","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[944,544]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"ba87a30b-feaa-4d5e-8bb5-41b51436f4da","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1136,544]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"2b608ad9-67af-4905-a2ff-7d613b7b67fe","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1344,544]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"4cd1054d-67e3-44ed-bc51-c595d5700a80","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1536,544]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID1').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"8b44c4e3-6d59-4476-926e-23518679def1","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1344,448]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"4c62182f-e3bb-47cc-8efa-dbf977221895","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1536,448]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"d4816c4b-8059-484a-b6d2-9b0fe1ff9e5c","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1744,448]},{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"b6cc62af-cedd-459f-bd88-487e2cdb8d02","name":"Webhook1","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[144,448],"webhookId":"transcribe-youtube"},{"parameters":{"jsCode":"const body = $input.first().json.body;\\nconst youtubeUrl = body.youtube_url || body.url;\\nconst useGemini = body.use_gemini !== false;\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"4520f0bf-1111-42b1-8b7a-edf80f22d185","name":"Extraire Video ID1","type":"n8n-nodes-base.code","typeVersion":2,"position":[336,448]}]	{"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]},"Webhook1":{"main":[[{"node":"Extraire Video ID1","type":"main","index":0}]]},"Extraire Video ID1":{"main":[[{"node":"Switch","type":"main","index":0}]]}}	Version 1c564b71	f	test
b4a67768-ecdc-4e3d-a46a-c834082b3f93	9dwHAWxj9YdjO2Ol	Channel Crypto	2025-12-18 21:36:45.061+00	2025-12-18 21:37:06.087+00	[{"parameters":{"rules":{"values":[{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":1},"conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}","id":"1deba6d9-96d6-4b10-9b2c-cc88230e573d"}],"combinator":"and"},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"caseSensitive":true,"leftValue":"","typeValidation":"strict","version":1},"conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}","id":"3face287-9a3b-415f-9297-91447916b6de"}],"combinator":"and"},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"21749132-c2af-4323-b1dc-645b7238c503","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[544,448]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"45292cee-20dc-483d-abeb-0400c00c6b22","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[736,336]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{"name":"contents","value":"={{ [{\\"parts\\": [{\\"text\\": \\"Transcris cette vidéo en français. Retourne uniquement le texte de la transcription, sans aucun formatage ni commentaire.\\"}, {\\"fileData\\": {\\"mimeType\\": \\"video/mp4\\", \\"fileUri\\": \\"gs://temp-bucket/\\" + $json.video_id + \\".mp4\\"}}]}] }}"}]},"options":{"timeout":300000}},"id":"299dc582-ec89-498a-a1aa-9f9ceb74cc90","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[944,336],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Download Video (Gemini)').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"8627e11e-1e32-4985-b645-da1491cb50ca","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1136,336]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"d2a966b3-2197-468e-8ef4-affc8c1952f7","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[736,544]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"1d9c94a0-1779-4262-8499-0d54f1b6dfdd","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[944,544]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"ba87a30b-feaa-4d5e-8bb5-41b51436f4da","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1136,544]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"2b608ad9-67af-4905-a2ff-7d613b7b67fe","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1344,544]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"4cd1054d-67e3-44ed-bc51-c595d5700a80","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1536,544]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID1').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"8b44c4e3-6d59-4476-926e-23518679def1","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1344,448]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"4c62182f-e3bb-47cc-8efa-dbf977221895","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1536,448]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"d4816c4b-8059-484a-b6d2-9b0fe1ff9e5c","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1744,448]},{"parameters":{"jsCode":"const body = $input.first().json.body;\\nconst youtubeUrl = body.youtube_url || body.url;\\nconst useGemini = body.use_gemini !== false;\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"4520f0bf-1111-42b1-8b7a-edf80f22d185","name":"Extraire Video ID1","type":"n8n-nodes-base.code","typeVersion":2,"position":[336,448]},{"parameters":{"formTitle":"Transcription YouTube","formDescription":"https://www.youtube.com/watch?v=suy4wc-t0kg","formFields":{"values":[{"fieldLabel":"youtube_url","placeholder":"https://www.youtube.com/watch?v=","requiredField":true},{"fieldLabel":"method","fieldType":"checkbox","fieldOptions":{"values":[{"option":"gemini"},{"option":"whisper"}]},"limitSelection":"exact","requiredField":true}]},"options":{}},"type":"n8n-nodes-base.formTrigger","typeVersion":2.3,"position":[112,448],"id":"41d0bede-58ea-4bec-a9a4-c63b458f4c62","name":"On form submission","webhookId":"a5a8a84a-97ba-4d04-aced-e35ff478dc5b"}]	{"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]},"Extraire Video ID1":{"main":[[{"node":"Switch","type":"main","index":0}]]},"On form submission":{"main":[[{"node":"Extraire Video ID1","type":"main","index":0}]]}}	Version b4a67768	f	on form submission - clic box\n
a74c79d0-284c-4d35-acd8-46fe2ac4489a	UzLhODuCRP8ffkct	Channel Crypto	2025-12-19 03:58:03.098+00	2025-12-19 03:58:03.098+00	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"webhook-001","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,400],"webhookId":"transcribe-youtube"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"extract-id-001","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,400]},{"parameters":{"mode":"rules","rules":{"values":[{"outputKey":"Gemini","conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true},{"outputKey":"Whisper","conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true}]},"options":{}},"id":"switch-001","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[650,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"download-gemini-001","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,300]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{"name":"contents","value":"={{ [{\\"parts\\": [{\\"text\\": \\"Transcris cette vidéo en français. Retourne uniquement le texte de la transcription, sans aucun formatage ni commentaire.\\"}, {\\"fileData\\": {\\"mimeType\\": \\"video/mp4\\", \\"fileUri\\": \\"gs://temp-bucket/\\" + $json.video_id + \\".mp4\\"}}]}] }}"}]},"options":{"timeout":300000}},"id":"gemini-api-001","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1050,300],"credentials":{"httpQueryAuth":{"id":"gemini-api-key","name":"Gemini API Key"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Download Video (Gemini)').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"parse-gemini-001","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,300]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"download-whisper-001","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"extract-audio-001","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1050,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"read-audio-001","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,500]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"name":"file","inputDataFieldName":"data","parameterType":"formBinaryData"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"whisper-api-001","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1450,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"parse-whisper-001","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"save-files-001","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1450,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"cleanup-001","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,400]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"response-001","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1850,400]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}}	\N	f	\N
58f1c494-b128-48b8-b0b9-e1102ca79c0b	R31TqM6ks1cBpLkA	Channel Crypto	2025-12-19 03:58:17.119+00	2025-12-19 05:16:30.838+00	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"webhook-001","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[250,400],"webhookId":"transcribe-youtube"},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"extract-id-001","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[450,400]},{"parameters":{"mode":"rules","rules":{"values":[{"outputKey":"Gemini","conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true},{"outputKey":"Whisper","conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true}]},"options":{}},"id":"switch-001","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[650,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"download-gemini-001","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,300]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{"name":"contents","value":"={{ [{\\"parts\\": [{\\"text\\": \\"Transcris cette vidéo en français. Retourne uniquement le texte de la transcription, sans aucun formatage ni commentaire.\\"}, {\\"fileData\\": {\\"mimeType\\": \\"video/mp4\\", \\"fileUri\\": \\"gs://temp-bucket/\\" + $json.video_id + \\".mp4\\"}}]}] }}"}]},"options":{"timeout":300000}},"id":"gemini-api-001","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1050,300],"credentials":{"httpQueryAuth":{"id":"gemini-api-key","name":"Gemini API Key"}}},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Download Video (Gemini)').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"parse-gemini-001","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,300]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"download-whisper-001","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[850,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"extract-audio-001","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1050,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"read-audio-001","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1250,500]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"name":"file","inputDataFieldName":"data","parameterType":"formBinaryData"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"whisper-api-001","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1450,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"parse-whisper-001","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,500]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"save-files-001","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1450,400]},{"parameters":{"mode":"runOnceForAllItems","language":"javaScript","jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"cleanup-001","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1650,400]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"response-001","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1850,400]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}}	Version 58f1c494	f	
afa13eef-06da-4b8d-9905-a94d6f6589df	ccdNWghInvBMCrnH	Channel Crypto	2025-12-19 05:51:36.677+00	2025-12-19 05:51:36.677+00	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"405730c6-38e3-4dc1-95c7-e4696b880dd6","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-608,112],"webhookId":"transcribe-youtube"},{"parameters":{"jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"4c06f121-280d-44fe-99ea-24780ebe0538","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[-400,112]},{"parameters":{"rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"2b54b86a-f1c6-49c4-a021-4046f530e091","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[-208,112]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"3b8cd616-0219-48c8-93d1-380d7561d6d1","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,0]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];"},"id":"02cce423-0c9d-4234-80b3-6042779673a2","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[208,0]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000}},"id":"1e223c96-e916-45da-95c2-547907ca7866","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[400,0],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];"},"id":"c29a740d-f1d8-4821-9641-9f5a14f9ca41","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[608,0]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{"timeout":600000}},"id":"bde81c2a-a39c-4623-bbe8-08bcecf67b20","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[800,0],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"cceb90e1-8cc6-4852-b286-2a668cd2e6d3","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1008,0]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"d865faaf-799c-4f47-befb-c83976b47c29","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[0,208]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `/home/ne0rignr/.local/bin/ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"b9387f0d-fe74-426f-8ba6-eaa4c7269d67","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[208,208]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"bc4f1cdf-3c1a-45e6-b4d2-3ffce9160b47","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[400,208]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"75724ba0-be7a-404d-87f9-e84278b4c21d","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[608,208]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"348f94a8-85f9-40a2-a75a-20aa8313ae0f","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[800,208]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"1498323f-b1cd-4075-9b70-5f8196c33907","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1200,112]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"0f3f713c-4b95-4c4f-9c48-516c0a254f1e","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[1408,112]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"11e61c14-6b3a-4c2a-828e-2e5212f3b786","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1600,112]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}}	\N	f	\N
0019a807-aeb0-4f3a-af28-6f6ca83f8a38	ccdNWghInvBMCrnH	Channel Crypto	2025-12-19 06:00:39.184+00	2025-12-19 06:00:39.184+00	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"1dda2a0a-c0f7-427b-be08-96b16614a399","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[624,96],"webhookId":"transcribe-youtube"},{"parameters":{"jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"9a268a0d-d00a-4545-8e8c-0690806b597a","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[816,96]},{"parameters":{"rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"ed604210-b9b5-4181-a835-ff7a3ff1742a","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[1024,96]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"c5bdbcc6-07ac-4ddd-8178-9e0b4514538e","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,-16]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];"},"id":"8b1394b5-337a-4863-aa2a-6bd952c32df9","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000}},"id":"49309b77-e1a5-4c63-b195-ef783d802f90","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1616,-16]},{"parameters":{"jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];"},"id":"6fe03172-6867-45cf-b044-447c7f8291ea","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1824,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{"timeout":600000}},"id":"06308c22-4095-4e61-a832-9703720d6cbf","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[2016,-16]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"d0a99abf-40a3-46c2-9ee0-23fd8bc94316","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2224,-16]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"847aa2d0-bace-4df8-aec4-91e01b05cf15","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,192]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `/home/ne0rignr/.local/bin/ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"b6e1e382-e7e5-42d1-95e7-a7067b6e11b1","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,192]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"4bdc2acd-cf3c-44cd-b19b-65b6d11e4522","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1616,192]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"6e7fd028-5580-42de-8087-eaf19079a765","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1824,192]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"57c973e5-b369-4d99-9b46-5b8f02549a96","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2016,192]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"d877c019-82fd-48de-8bec-6471f8328ca9","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[2416,96]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"7f55a96b-19fe-47f7-9c41-9f3d2ace4446","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[2624,96]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"064bbacf-086b-46c6-9da4-55be014423ce","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[2816,96]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}}	\N	f	\N
0029645d-df58-4d72-8013-0bb7cf1dcdc1	ccdNWghInvBMCrnH	Channel Crypto	2025-12-19 06:06:43.052+00	2025-12-19 06:06:43.052+00	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"1dda2a0a-c0f7-427b-be08-96b16614a399","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[624,96],"webhookId":"transcribe-youtube"},{"parameters":{"jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"9a268a0d-d00a-4545-8e8c-0690806b597a","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[816,96]},{"parameters":{"rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"ed604210-b9b5-4181-a835-ff7a3ff1742a","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[1024,96]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"c5bdbcc6-07ac-4ddd-8178-9e0b4514538e","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,-16]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];"},"id":"8b1394b5-337a-4863-aa2a-6bd952c32df9","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000}},"id":"49309b77-e1a5-4c63-b195-ef783d802f90","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1616,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];"},"id":"6fe03172-6867-45cf-b044-447c7f8291ea","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1824,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{"timeout":600000}},"id":"06308c22-4095-4e61-a832-9703720d6cbf","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[2016,-16]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"d0a99abf-40a3-46c2-9ee0-23fd8bc94316","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2224,-16]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"847aa2d0-bace-4df8-aec4-91e01b05cf15","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,192]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `/home/ne0rignr/.local/bin/ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"b6e1e382-e7e5-42d1-95e7-a7067b6e11b1","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,192]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"4bdc2acd-cf3c-44cd-b19b-65b6d11e4522","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1616,192]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"6e7fd028-5580-42de-8087-eaf19079a765","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1824,192]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"57c973e5-b369-4d99-9b46-5b8f02549a96","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2016,192]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"d877c019-82fd-48de-8bec-6471f8328ca9","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[2416,96]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"7f55a96b-19fe-47f7-9c41-9f3d2ace4446","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[2624,96]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"064bbacf-086b-46c6-9da4-55be014423ce","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[2816,96]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}}	\N	f	\N
0b5bec6a-79f9-405b-8566-d059056d3baf	ccdNWghInvBMCrnH	Channel Crypto	2025-12-19 06:06:53.582+00	2025-12-19 06:06:56.366+00	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"1dda2a0a-c0f7-427b-be08-96b16614a399","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[624,96],"webhookId":"transcribe-youtube"},{"parameters":{"jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"9a268a0d-d00a-4545-8e8c-0690806b597a","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[816,96]},{"parameters":{"rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"ed604210-b9b5-4181-a835-ff7a3ff1742a","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[1024,96]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'gemini'\\n  }\\n}];"},"id":"c5bdbcc6-07ac-4ddd-8178-9e0b4514538e","name":"Download Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,-16]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];"},"id":"8b1394b5-337a-4863-aa2a-6bd952c32df9","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000}},"id":"49309b77-e1a5-4c63-b195-ef783d802f90","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1616,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];"},"id":"6fe03172-6867-45cf-b044-447c7f8291ea","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1824,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{"timeout":600000}},"id":"06308c22-4095-4e61-a832-9703720d6cbf","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[2016,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"d0a99abf-40a3-46c2-9ee0-23fd8bc94316","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2224,-16]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst youtubeUrl = $input.first().json.youtube_url;\\n\\nconst command = `cd /tmp && /home/ne0rignr/.local/bin/yt-dlp -f 'best[ext=mp4]' -o '${videoId}.mp4' '${youtubeUrl}' 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    youtube_url: youtubeUrl,\\n    video_path: `/tmp/${videoId}.mp4`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"847aa2d0-bace-4df8-aec4-91e01b05cf15","name":"Download Video (Whisper)","type":"n8n-nodes-base.code","typeVersion":2,"position":[1216,192]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst command = `/home/ne0rignr/.local/bin/ffmpeg -i \\"${videoPath}\\" -vn -ar 16000 -ac 1 -b:a 64k -y \\"/tmp/${videoId}.mp3\\" 2>&1`;\\nconst output = execSync(command, { encoding: 'utf-8', maxBuffer: 10 * 1024 * 1024 });\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    audio_path: `/tmp/${videoId}.mp3`,\\n    method: 'whisper'\\n  }\\n}];"},"id":"b6e1e382-e7e5-42d1-95e7-a7067b6e11b1","name":"Extract Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1424,192]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"4bdc2acd-cf3c-44cd-b19b-65b6d11e4522","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[1616,192]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"6e7fd028-5580-42de-8087-eaf19079a765","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[1824,192]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"57c973e5-b369-4d99-9b46-5b8f02549a96","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[2016,192]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"d877c019-82fd-48de-8bec-6471f8328ca9","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[2416,96]},{"parameters":{"jsCode":"const { execSync } = require('child_process');\\nconst videoId = $input.first().json.video_id;\\n\\nconst commands = [\\n  `rm -f /tmp/${videoId}.mp4`,\\n  `rm -f /tmp/${videoId}.mp3`\\n];\\n\\ntry {\\n  commands.forEach(cmd => execSync(cmd, { encoding: 'utf-8' }));\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: true\\n    }\\n  }];\\n} catch (error) {\\n  return [{\\n    json: {\\n      ...$input.first().json,\\n      cleanup_success: false\\n    }\\n  }];\\n}"},"id":"7f55a96b-19fe-47f7-9c41-9f3d2ace4446","name":"Cleanup","type":"n8n-nodes-base.code","typeVersion":2,"position":[2624,96]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"064bbacf-086b-46c6-9da4-55be014423ce","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[2816,96]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Switch":{"main":[[{"node":"Download Video (Gemini)","type":"main","index":0}],[{"node":"Download Video (Whisper)","type":"main","index":0}]]},"Download Video (Gemini)":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Download Video (Whisper)":{"main":[[{"node":"Extract Audio","type":"main","index":0}]]},"Extract Audio":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Save Files":{"main":[[{"node":"Cleanup","type":"main","index":0}]]},"Cleanup":{"main":[[{"node":"Response","type":"main","index":0}]]}}	Version 0b5bec6a	f	
623a115a-aa3e-4df4-a670-62cac5873694	nAA8iukS0ukDaeqK	Channel Crypto	2025-12-19 07:47:22.002+00	2025-12-19 07:47:22.002+00	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"b0db5c3d-b916-4c37-b087-776533709d86","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-624,128],"webhookId":"transcribe-youtube"},{"parameters":{"jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"f98e78c6-5f46-4323-a8af-64338cc55703","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[-416,144]},{"parameters":{"rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"ebbaf736-0ca3-4f92-91ea-c6df00fda78d","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[-224,144]},{"parameters":{},"id":"ecbefe89-e866-4e80-b5c8-c0e8f2a7337b","name":"Download Video (Gemini)","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[-48,-16]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Extraire Video ID').item.json.video_id }}","type":"string"},{"id":"youtube_url","name":"youtube_url","value":"={{ $('Extraire Video ID').item.json.youtube_url }}","type":"string"},{"id":"video_path","name":"video_path","value":"=/tmp/{{ $('Extraire Video ID').item.json.video_id }}.mp4","type":"string"},{"id":"method","name":"method","value":"gemini","type":"string"}]},"options":{}},"id":"32c2c47f-3539-40be-a5e6-9c7a4e036ade","name":"Set Gemini Data","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[80,-32]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];"},"id":"315f70f7-4271-4125-a231-df559c55aad9","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[272,-64]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000}},"id":"cb7d8b46-b3a1-4819-8c52-4bdf48759f4d","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[448,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];"},"id":"10f808b6-2cbc-4a1e-8b2c-87548f4d1fb1","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[640,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{"timeout":600000}},"id":"c0ac21c8-2d2d-4d01-b994-55b6f550b73d","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[832,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"8d391bd8-35cf-4924-92eb-77fc28d3c6f2","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1008,0]},{"parameters":{},"id":"a468e76b-d713-4af4-9746-dbfeb27cf840","name":"Download Video (Whisper)","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[-96,288]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Extraire Video ID').item.json.video_id }}","type":"string"},{"id":"youtube_url","name":"youtube_url","value":"={{ $('Extraire Video ID').item.json.youtube_url }}","type":"string"},{"id":"video_path","name":"video_path","value":"=/tmp/{{ $('Extraire Video ID').item.json.video_id }}.mp4","type":"string"},{"id":"method","name":"method","value":"whisper","type":"string"}]},"options":{}},"id":"2b04f062-65c4-4b77-8d43-de5fa9726794","name":"Set Whisper Data","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[48,288]},{"parameters":{},"id":"9ffd9cd8-9e48-4f51-b563-b24cc92f0e8a","name":"Extract Audio","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[224,288]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Set Whisper Data').item.json.video_id }}","type":"string"},{"id":"audio_path","name":"audio_path","value":"=/tmp/{{ $('Set Whisper Data').item.json.video_id }}.mp3","type":"string"},{"id":"method","name":"method","value":"whisper","type":"string"}]},"options":{}},"id":"23121148-c1b4-4bf8-b14f-c727cd9315df","name":"Set Audio Data","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[352,288]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"a5cd0e1c-8605-463a-ba64-9a9e35916254","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[512,256]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"2a49b346-64f7-4e43-aadc-b6d8ab5edc2b","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[704,256]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"c521435b-30a2-4b24-9a6f-c724d3304d96","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[896,208]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"fe6e299a-7e67-4758-af23-6f6f1a7ad4ab","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1200,112]},{"parameters":{},"id":"e51e8c15-b1e2-4511-a5bf-cd56f07a19fa","name":"Cleanup","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[1344,112]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Save Files').item.json.video_id }}","type":"string"},{"id":"method","name":"method","value":"={{ $('Save Files').item.json.method }}","type":"string"},{"id":"output_dir","name":"output_dir","value":"={{ $('Save Files').item.json.output_dir }}","type":"string"},{"id":"text_length","name":"text_length","value":"={{ $('Save Files').item.json.text_length }}","type":"number"},{"id":"cleanup_success","name":"cleanup_success","value":true,"type":"boolean"}]},"options":{}},"id":"0f2e0c8a-3688-4d49-8b62-9679bc838788","name":"Set Cleanup Result","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[1520,112]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"433215d8-1bcb-4318-8dfc-cfd5214ecf5d","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1664,112]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Set Gemini Data":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Set Audio Data":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Set Cleanup Result":{"main":[[{"node":"Response","type":"main","index":0}]]}}	\N	f	\N
b3429838-5dbc-431e-a95e-eb750b9a20b1	nAA8iukS0ukDaeqK	Channel Crypto	2025-12-19 08:18:29.671+00	2025-12-19 08:18:29.671+00	[{"parameters":{"httpMethod":"POST","path":"transcribe","responseMode":"responseNode","options":{}},"id":"b0db5c3d-b916-4c37-b087-776533709d86","name":"Webhook","type":"n8n-nodes-base.webhook","typeVersion":2,"position":[-624,128],"webhookId":"transcribe-youtube"},{"parameters":{"jsCode":"const body = $input.first().json.body || $input.first().json;\\n\\n// Accept either a 'method' field (string or array from checkboxes) or a 'use_gemini' boolean/string\\nconst youtubeUrl = body.youtube_url || body.url || body.youtube || body.input_url;\\nlet useGemini = true;\\n\\nif (body.method !== undefined) {\\n  const m = body.method;\\n  if (Array.isArray(m)) {\\n    const lowered = m.map(x => String(x).toLowerCase());\\n    if (lowered.includes('whisper') && !lowered.includes('gemini')) {\\n      useGemini = false;\\n    } else if (lowered.includes('gemini') && !lowered.includes('whisper')) {\\n      useGemini = true;\\n    } else if (lowered.includes('gemini') && lowered.includes('whisper')) {\\n      // both selected: prefer gemini by default\\n      useGemini = true;\\n    } else {\\n      // unknown selection: fallback to true\\n      useGemini = true;\\n    }\\n  } else {\\n    const ms = String(m).toLowerCase();\\n    useGemini = (ms === 'gemini' || ms === 'true' || ms === '1' || ms === 'yes');\\n  }\\n} else if (body.use_gemini !== undefined) {\\n  const ug = body.use_gemini;\\n  if (typeof ug === 'boolean') {\\n    useGemini = ug;\\n  } else {\\n    const s = String(ug).toLowerCase();\\n    useGemini = (s === 'true' || s === '1' || s === 'yes' || s === 'gemini');\\n  }\\n}\\n\\nif (!youtubeUrl) {\\n  throw new Error('URL YouTube manquante');\\n}\\n\\nconst youtubeRegex = /(?:youtube\\\\.com\\\\/(?:[^\\\\/]+\\\\/.+\\\\/|(?:v|e(?:mbed)?)\\\\/|.*[?&]v=)|youtu\\\\.be\\\\/)([^\\"&?\\\\/ ]{11})/;\\nconst match = youtubeUrl.match(youtubeRegex);\\n\\nif (!match || !match[1]) {\\n  throw new Error('URL YouTube invalide');\\n}\\n\\nreturn [{\\n  json: {\\n    youtube_url: youtubeUrl,\\n    video_id: match[1],\\n    use_gemini: useGemini,\\n    timestamp: new Date().toISOString()\\n  }\\n}];"},"id":"f98e78c6-5f46-4323-a8af-64338cc55703","name":"Extraire Video ID","type":"n8n-nodes-base.code","typeVersion":2,"position":[-416,144]},{"parameters":{"rules":{"values":[{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"true"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Gemini"},{"conditions":{"options":{"version":2},"combinator":"and","conditions":[{"operator":{"type":"boolean","operation":"false"},"leftValue":"={{ $json.use_gemini }}"}]},"renameOutput":true,"outputKey":"Whisper"}]},"options":{}},"id":"ebbaf736-0ca3-4f92-91ea-c6df00fda78d","name":"Switch","type":"n8n-nodes-base.switch","typeVersion":3,"position":[-224,144]},{"parameters":{},"id":"ecbefe89-e866-4e80-b5c8-c0e8f2a7337b","name":"Download Video (Gemini)","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[-48,-16]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Extraire Video ID').item.json.video_id }}","type":"string"},{"id":"youtube_url","name":"youtube_url","value":"={{ $('Extraire Video ID').item.json.youtube_url }}","type":"string"},{"id":"video_path","name":"video_path","value":"=/tmp/{{ $('Extraire Video ID').item.json.video_id }}.mp4","type":"string"},{"id":"method","name":"method","value":"gemini","type":"string"}]},"options":{}},"id":"32c2c47f-3539-40be-a5e6-9c7a4e036ade","name":"Set Gemini Data","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[80,-32]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst videoPath = $input.first().json.video_path;\\n\\nconst videoBuffer = fs.readFileSync(videoPath);\\nconst videoBase64 = videoBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    video_path: videoPath,\\n    method: 'gemini'\\n  },\\n  binary: {\\n    video: {\\n      data: videoBase64,\\n      mimeType: 'video/mp4',\\n      fileName: `${videoId}.mp4`\\n    }\\n  }\\n}];"},"id":"315f70f7-4271-4125-a231-df559c55aad9","name":"Read Video (Gemini)","type":"n8n-nodes-base.code","typeVersion":2,"position":[272,-64]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/upload/v1beta/files","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendHeaders":true,"headerParameters":{"parameters":[{"name":"X-Goog-Upload-Protocol","value":"multipart"}]},"sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"video"}]},"options":{"timeout":600000}},"id":"cb7d8b46-b3a1-4819-8c52-4bdf48759f4d","name":"Upload to Gemini Files","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[448,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const uploadResponse = $input.first().json;\\nconst videoId = $('Read Video (Gemini)').first().json.video_id;\\n\\nif (!uploadResponse.file || !uploadResponse.file.uri) {\\n  throw new Error('Upload failed: ' + JSON.stringify(uploadResponse));\\n}\\n\\nconst fileUri = uploadResponse.file.uri;\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    file_uri: fileUri,\\n    file_name: uploadResponse.file.name,\\n    method: 'gemini'\\n  }\\n}];"},"id":"10f808b6-2cbc-4a1e-8b2c-87548f4d1fb1","name":"Parse Upload Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[640,-16]},{"parameters":{"method":"POST","url":"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash-exp:generateContent","authentication":"genericCredentialType","genericAuthType":"httpQueryAuth","sendBody":true,"bodyParameters":{"parameters":[{}]},"options":{"timeout":600000}},"id":"c0ac21c8-2d2d-4d01-b994-55b6f550b73d","name":"Gemini 2.0 Flash","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[832,-16],"credentials":{"httpQueryAuth":{"id":"I3D538Occ66Sb5YV","name":"Query Auth account"}}},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Parse Upload Response').first().json.video_id;\\n\\nlet transcriptionText = '';\\n\\nif (response.candidates && response.candidates[0]) {\\n  const content = response.candidates[0].content;\\n  if (content && content.parts) {\\n    transcriptionText = content.parts.map(p => p.text).join('');\\n  }\\n}\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Gemini');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'gemini',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"8d391bd8-35cf-4924-92eb-77fc28d3c6f2","name":"Parse Gemini Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[1008,0]},{"parameters":{},"id":"a468e76b-d713-4af4-9746-dbfeb27cf840","name":"Download Video (Whisper)","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[-96,288]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Extraire Video ID').item.json.video_id }}","type":"string"},{"id":"youtube_url","name":"youtube_url","value":"={{ $('Extraire Video ID').item.json.youtube_url }}","type":"string"},{"id":"video_path","name":"video_path","value":"=/tmp/{{ $('Extraire Video ID').item.json.video_id }}.mp4","type":"string"},{"id":"method","name":"method","value":"whisper","type":"string"}]},"options":{}},"id":"2b04f062-65c4-4b77-8d43-de5fa9726794","name":"Set Whisper Data","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[48,288]},{"parameters":{},"id":"9ffd9cd8-9e48-4f51-b563-b24cc92f0e8a","name":"Extract Audio","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[224,288]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Set Whisper Data').item.json.video_id }}","type":"string"},{"id":"audio_path","name":"audio_path","value":"=/tmp/{{ $('Set Whisper Data').item.json.video_id }}.mp3","type":"string"},{"id":"method","name":"method","value":"whisper","type":"string"}]},"options":{}},"id":"23121148-c1b4-4bf8-b14f-c727cd9315df","name":"Set Audio Data","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[352,288]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst videoId = $input.first().json.video_id;\\nconst audioPath = $input.first().json.audio_path;\\n\\nconst audioBuffer = fs.readFileSync(audioPath);\\nconst audioBase64 = audioBuffer.toString('base64');\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: 'whisper'\\n  },\\n  binary: {\\n    data: {\\n      data: audioBase64,\\n      mimeType: 'audio/mpeg',\\n      fileName: `${videoId}.mp3`\\n    }\\n  }\\n}];"},"id":"a5cd0e1c-8605-463a-ba64-9a9e35916254","name":"Read Audio","type":"n8n-nodes-base.code","typeVersion":2,"position":[512,256]},{"parameters":{"method":"POST","url":"http://localhost:9000/transcribe","sendBody":true,"contentType":"multipart-form-data","bodyParameters":{"parameters":[{"parameterType":"formBinaryData","name":"file","inputDataFieldName":"data"},{"name":"language","value":"fr"}]},"options":{"timeout":3600000}},"id":"2a49b346-64f7-4e43-aadc-b6d8ab5edc2b","name":"Whisper API","type":"n8n-nodes-base.httpRequest","typeVersion":4.2,"position":[704,256]},{"parameters":{"jsCode":"const response = $input.first().json;\\nconst videoId = $('Read Audio').first().json.video_id;\\n\\nconst transcriptionText = response.text || response.transcription || '';\\n\\nif (!transcriptionText) {\\n  throw new Error('Pas de transcription reçue de Whisper');\\n}\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    transcription: transcriptionText,\\n    method: 'whisper',\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"c521435b-30a2-4b24-9a6f-c724d3304d96","name":"Parse Whisper Response","type":"n8n-nodes-base.code","typeVersion":2,"position":[896,208]},{"parameters":{"jsCode":"const fs = require('fs');\\nconst path = require('path');\\n\\nconst data = $input.first().json;\\nconst videoId = data.video_id;\\nconst transcriptionText = data.transcription;\\nconst method = data.method;\\n\\nconst baseDir = '/home/ne0rignr/workspace-serveur/transcriptions';\\nconst outputDir = path.join(baseDir, videoId);\\n\\nif (!fs.existsSync(outputDir)) {\\n  fs.mkdirSync(outputDir, { recursive: true });\\n}\\n\\nconst transcriptionPath = path.join(outputDir, 'transcription_brute.txt');\\nfs.writeFileSync(transcriptionPath, transcriptionText);\\n\\nconst metadata = {\\n  video_id: videoId,\\n  youtube_url: $('Extraire Video ID').first().json.youtube_url,\\n  transcription_method: method,\\n  transcription_date: new Date().toISOString(),\\n  text_length: transcriptionText.length\\n};\\n\\nconst metadataPath = path.join(outputDir, 'metadata.json');\\nfs.writeFileSync(metadataPath, JSON.stringify(metadata, null, 2));\\n\\nreturn [{\\n  json: {\\n    video_id: videoId,\\n    method: method,\\n    output_dir: outputDir,\\n    transcription_path: transcriptionPath,\\n    metadata_path: metadataPath,\\n    text_length: transcriptionText.length\\n  }\\n}];"},"id":"fe6e299a-7e67-4758-af23-6f6f1a7ad4ab","name":"Save Files","type":"n8n-nodes-base.code","typeVersion":2,"position":[1200,112]},{"parameters":{},"id":"e51e8c15-b1e2-4511-a5bf-cd56f07a19fa","name":"Cleanup","type":"n8n-nodes-base.executeCommand","typeVersion":1,"position":[1344,112]},{"parameters":{"assignments":{"assignments":[{"id":"video_id","name":"video_id","value":"={{ $('Save Files').item.json.video_id }}","type":"string"},{"id":"method","name":"method","value":"={{ $('Save Files').item.json.method }}","type":"string"},{"id":"output_dir","name":"output_dir","value":"={{ $('Save Files').item.json.output_dir }}","type":"string"},{"id":"text_length","name":"text_length","value":"={{ $('Save Files').item.json.text_length }}","type":"number"},{"id":"cleanup_success","name":"cleanup_success","value":true,"type":"boolean"}]},"options":{}},"id":"0f2e0c8a-3688-4d49-8b62-9679bc838788","name":"Set Cleanup Result","type":"n8n-nodes-base.set","typeVersion":3.4,"position":[1520,112]},{"parameters":{"respondWith":"json","responseBody":"={{ {\\n  \\"success\\": true,\\n  \\"message\\": \\"Transcription terminée\\",\\n  \\"video_id\\": $json.video_id,\\n  \\"method\\": $json.method,\\n  \\"output_directory\\": $json.output_dir,\\n  \\"text_length\\": $json.text_length,\\n  \\"cleanup_success\\": $json.cleanup_success\\n} }}","options":{}},"id":"433215d8-1bcb-4318-8dfc-cfd5214ecf5d","name":"Response","type":"n8n-nodes-base.respondToWebhook","typeVersion":1.4,"position":[1664,112]}]	{"Webhook":{"main":[[{"node":"Extraire Video ID","type":"main","index":0}]]},"Extraire Video ID":{"main":[[{"node":"Switch","type":"main","index":0}]]},"Set Gemini Data":{"main":[[{"node":"Read Video (Gemini)","type":"main","index":0}]]},"Read Video (Gemini)":{"main":[[{"node":"Upload to Gemini Files","type":"main","index":0}]]},"Upload to Gemini Files":{"main":[[{"node":"Parse Upload Response","type":"main","index":0}]]},"Parse Upload Response":{"main":[[{"node":"Gemini 2.0 Flash","type":"main","index":0}]]},"Gemini 2.0 Flash":{"main":[[{"node":"Parse Gemini Response","type":"main","index":0}]]},"Parse Gemini Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Set Audio Data":{"main":[[{"node":"Read Audio","type":"main","index":0}]]},"Read Audio":{"main":[[{"node":"Whisper API","type":"main","index":0}]]},"Whisper API":{"main":[[{"node":"Parse Whisper Response","type":"main","index":0}]]},"Parse Whisper Response":{"main":[[{"node":"Save Files","type":"main","index":0}]]},"Set Cleanup Result":{"main":[[{"node":"Response","type":"main","index":0}]]}}	\N	f	\N
\.


--
-- Data for Name: workflow_publish_history; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.workflow_publish_history (id, "workflowId", "versionId", event, "userId", "createdAt") FROM stdin;
1	9dwHAWxj9YdjO2Ol	1c564b71-19f5-413a-ad06-14d84d823206	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-18 19:44:36.251+00
2	9dwHAWxj9YdjO2Ol	1c564b71-19f5-413a-ad06-14d84d823206	deactivated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-18 19:49:45.094+00
3	9dwHAWxj9YdjO2Ol	1c564b71-19f5-413a-ad06-14d84d823206	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-18 19:49:54.126+00
4	9dwHAWxj9YdjO2Ol	1c564b71-19f5-413a-ad06-14d84d823206	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-18 19:51:33.305+00
5	9dwHAWxj9YdjO2Ol	1c564b71-19f5-413a-ad06-14d84d823206	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-18 21:36:45.13+00
6	9dwHAWxj9YdjO2Ol	b4a67768-ecdc-4e3d-a46a-c834082b3f93	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-18 21:37:06.086+00
7	R31TqM6ks1cBpLkA	58f1c494-b128-48b8-b0b9-e1102ca79c0b	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 04:08:47.961+00
8	R31TqM6ks1cBpLkA	58f1c494-b128-48b8-b0b9-e1102ca79c0b	deactivated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 05:11:05.158+00
9	9dwHAWxj9YdjO2Ol	b4a67768-ecdc-4e3d-a46a-c834082b3f93	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 05:13:13.796+00
10	9dwHAWxj9YdjO2Ol	b4a67768-ecdc-4e3d-a46a-c834082b3f93	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 05:13:32.926+00
11	9dwHAWxj9YdjO2Ol	b4a67768-ecdc-4e3d-a46a-c834082b3f93	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 05:13:41.552+00
12	9dwHAWxj9YdjO2Ol	b4a67768-ecdc-4e3d-a46a-c834082b3f93	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 05:14:00.705+00
13	R31TqM6ks1cBpLkA	58f1c494-b128-48b8-b0b9-e1102ca79c0b	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 05:16:30.837+00
14	R31TqM6ks1cBpLkA	58f1c494-b128-48b8-b0b9-e1102ca79c0b	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 05:16:39.646+00
15	R31TqM6ks1cBpLkA	58f1c494-b128-48b8-b0b9-e1102ca79c0b	deactivated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 05:57:41.993+00
16	9dwHAWxj9YdjO2Ol	b4a67768-ecdc-4e3d-a46a-c834082b3f93	deactivated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 05:57:58.168+00
17	ccdNWghInvBMCrnH	0b5bec6a-79f9-405b-8566-d059056d3baf	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 06:06:56.364+00
18	ccdNWghInvBMCrnH	0b5bec6a-79f9-405b-8566-d059056d3baf	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 06:07:25.743+00
19	ccdNWghInvBMCrnH	0b5bec6a-79f9-405b-8566-d059056d3baf	activated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 06:26:14.11+00
20	ccdNWghInvBMCrnH	0b5bec6a-79f9-405b-8566-d059056d3baf	deactivated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 07:05:04.446+00
21	nAA8iukS0ukDaeqK	623a115a-aa3e-4df4-a670-62cac5873694	deactivated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 07:47:25.158+00
22	nAA8iukS0ukDaeqK	623a115a-aa3e-4df4-a670-62cac5873694	deactivated	6c7170ed-e8fd-4326-af89-3939ab5befbb	2025-12-19 07:47:30.181+00
\.


--
-- Data for Name: workflow_statistics; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.workflow_statistics (count, "latestEvent", name, "workflowId", "rootCount") FROM stdin;
1	2025-12-18 20:00:53.705+00	manual_success	9dwHAWxj9YdjO2Ol	0
1	2025-12-19 05:53:38.608+00	data_loaded	R31TqM6ks1cBpLkA	1
2	2025-12-19 05:54:05.386+00	production_error	R31TqM6ks1cBpLkA	2
1	2025-12-19 06:31:32.681+00	data_loaded	ccdNWghInvBMCrnH	1
3	2025-12-19 06:34:04.185+00	production_error	ccdNWghInvBMCrnH	3
\.


--
-- Data for Name: workflows_tags; Type: TABLE DATA; Schema: public; Owner: n8n
--

COPY public.workflows_tags ("workflowId", "tagId") FROM stdin;
\.


--
-- Name: auth_provider_sync_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public.auth_provider_sync_history_id_seq', 1, false);


--
-- Name: execution_annotations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public.execution_annotations_id_seq', 1, false);


--
-- Name: execution_entity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public.execution_entity_id_seq', 6, true);


--
-- Name: execution_metadata_temp_id_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public.execution_metadata_temp_id_seq', 1, false);


--
-- Name: insights_by_period_id_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public.insights_by_period_id_seq', 8, true);


--
-- Name: insights_metadata_metaId_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public."insights_metadata_metaId_seq"', 2, true);


--
-- Name: insights_raw_id_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public.insights_raw_id_seq', 10, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public.migrations_id_seq', 123, true);


--
-- Name: oauth_user_consents_id_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public.oauth_user_consents_id_seq', 1, false);


--
-- Name: workflow_dependency_id_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public.workflow_dependency_id_seq', 1, false);


--
-- Name: workflow_publish_history_id_seq; Type: SEQUENCE SET; Schema: public; Owner: n8n
--

SELECT pg_catalog.setval('public.workflow_publish_history_id_seq', 22, true);


--
-- Name: test_run PK_011c050f566e9db509a0fadb9b9; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.test_run
    ADD CONSTRAINT "PK_011c050f566e9db509a0fadb9b9" PRIMARY KEY (id);


--
-- Name: installed_packages PK_08cc9197c39b028c1e9beca225940576fd1a5804; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.installed_packages
    ADD CONSTRAINT "PK_08cc9197c39b028c1e9beca225940576fd1a5804" PRIMARY KEY ("packageName");


--
-- Name: execution_metadata PK_17a0b6284f8d626aae88e1c16e4; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_metadata
    ADD CONSTRAINT "PK_17a0b6284f8d626aae88e1c16e4" PRIMARY KEY (id);


--
-- Name: project_relation PK_1caaa312a5d7184a003be0f0cb6; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "PK_1caaa312a5d7184a003be0f0cb6" PRIMARY KEY ("projectId", "userId");


--
-- Name: chat_hub_sessions PK_1eafef1273c70e4464fec703412; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "PK_1eafef1273c70e4464fec703412" PRIMARY KEY (id);


--
-- Name: folder_tag PK_27e4e00852f6b06a925a4d83a3e; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.folder_tag
    ADD CONSTRAINT "PK_27e4e00852f6b06a925a4d83a3e" PRIMARY KEY ("folderId", "tagId");


--
-- Name: role PK_35c9b140caaf6da09cfabb0d675; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.role
    ADD CONSTRAINT "PK_35c9b140caaf6da09cfabb0d675" PRIMARY KEY (slug);


--
-- Name: project PK_4d68b1358bb5b766d3e78f32f57; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.project
    ADD CONSTRAINT "PK_4d68b1358bb5b766d3e78f32f57" PRIMARY KEY (id);


--
-- Name: workflow_dependency PK_52325e34cd7a2f0f67b0f3cad65; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_dependency
    ADD CONSTRAINT "PK_52325e34cd7a2f0f67b0f3cad65" PRIMARY KEY (id);


--
-- Name: invalid_auth_token PK_5779069b7235b256d91f7af1a15; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.invalid_auth_token
    ADD CONSTRAINT "PK_5779069b7235b256d91f7af1a15" PRIMARY KEY (token);


--
-- Name: shared_workflow PK_5ba87620386b847201c9531c58f; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.shared_workflow
    ADD CONSTRAINT "PK_5ba87620386b847201c9531c58f" PRIMARY KEY ("workflowId", "projectId");


--
-- Name: folder PK_6278a41a706740c94c02e288df8; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT "PK_6278a41a706740c94c02e288df8" PRIMARY KEY (id);


--
-- Name: data_table_column PK_673cb121ee4a8a5e27850c72c51; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.data_table_column
    ADD CONSTRAINT "PK_673cb121ee4a8a5e27850c72c51" PRIMARY KEY (id);


--
-- Name: annotation_tag_entity PK_69dfa041592c30bbc0d4b84aa00; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.annotation_tag_entity
    ADD CONSTRAINT "PK_69dfa041592c30bbc0d4b84aa00" PRIMARY KEY (id);


--
-- Name: oauth_refresh_tokens PK_74abaed0b30711b6532598b0392; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_refresh_tokens
    ADD CONSTRAINT "PK_74abaed0b30711b6532598b0392" PRIMARY KEY (token);


--
-- Name: chat_hub_messages PK_7704a5add6baed43eef835f0bfb; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "PK_7704a5add6baed43eef835f0bfb" PRIMARY KEY (id);


--
-- Name: execution_annotations PK_7afcf93ffa20c4252869a7c6a23; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_annotations
    ADD CONSTRAINT "PK_7afcf93ffa20c4252869a7c6a23" PRIMARY KEY (id);


--
-- Name: oauth_user_consents PK_85b9ada746802c8993103470f05; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "PK_85b9ada746802c8993103470f05" PRIMARY KEY (id);


--
-- Name: migrations PK_8c82d7f526340ab734260ea46be; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT "PK_8c82d7f526340ab734260ea46be" PRIMARY KEY (id);


--
-- Name: installed_nodes PK_8ebd28194e4f792f96b5933423fc439df97d9689; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.installed_nodes
    ADD CONSTRAINT "PK_8ebd28194e4f792f96b5933423fc439df97d9689" PRIMARY KEY (name);


--
-- Name: shared_credentials PK_8ef3a59796a228913f251779cff; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.shared_credentials
    ADD CONSTRAINT "PK_8ef3a59796a228913f251779cff" PRIMARY KEY ("credentialsId", "projectId");


--
-- Name: test_case_execution PK_90c121f77a78a6580e94b794bce; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.test_case_execution
    ADD CONSTRAINT "PK_90c121f77a78a6580e94b794bce" PRIMARY KEY (id);


--
-- Name: user_api_keys PK_978fa5caa3468f463dac9d92e69; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.user_api_keys
    ADD CONSTRAINT "PK_978fa5caa3468f463dac9d92e69" PRIMARY KEY (id);


--
-- Name: execution_annotation_tags PK_979ec03d31294cca484be65d11f; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_annotation_tags
    ADD CONSTRAINT "PK_979ec03d31294cca484be65d11f" PRIMARY KEY ("annotationId", "tagId");


--
-- Name: webhook_entity PK_b21ace2e13596ccd87dc9bf4ea6; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.webhook_entity
    ADD CONSTRAINT "PK_b21ace2e13596ccd87dc9bf4ea6" PRIMARY KEY ("webhookPath", method);


--
-- Name: insights_by_period PK_b606942249b90cc39b0265f0575; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.insights_by_period
    ADD CONSTRAINT "PK_b606942249b90cc39b0265f0575" PRIMARY KEY (id);


--
-- Name: workflow_history PK_b6572dd6173e4cd06fe79937b58; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_history
    ADD CONSTRAINT "PK_b6572dd6173e4cd06fe79937b58" PRIMARY KEY ("versionId");


--
-- Name: scope PK_bfc45df0481abd7f355d6187da1; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.scope
    ADD CONSTRAINT "PK_bfc45df0481abd7f355d6187da1" PRIMARY KEY (slug);


--
-- Name: oauth_clients PK_c4759172d3431bae6f04e678e0d; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_clients
    ADD CONSTRAINT "PK_c4759172d3431bae6f04e678e0d" PRIMARY KEY (id);


--
-- Name: workflow_publish_history PK_c788f7caf88e91e365c97d6d04a; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_publish_history
    ADD CONSTRAINT "PK_c788f7caf88e91e365c97d6d04a" PRIMARY KEY (id);


--
-- Name: processed_data PK_ca04b9d8dc72de268fe07a65773; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.processed_data
    ADD CONSTRAINT "PK_ca04b9d8dc72de268fe07a65773" PRIMARY KEY ("workflowId", context);


--
-- Name: settings PK_dc0fe14e6d9943f268e7b119f69ab8bd; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT "PK_dc0fe14e6d9943f268e7b119f69ab8bd" PRIMARY KEY (key);


--
-- Name: oauth_access_tokens PK_dcd71f96a5d5f4bf79e67d322bf; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT "PK_dcd71f96a5d5f4bf79e67d322bf" PRIMARY KEY (token);


--
-- Name: data_table PK_e226d0001b9e6097cbfe70617cb; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.data_table
    ADD CONSTRAINT "PK_e226d0001b9e6097cbfe70617cb" PRIMARY KEY (id);


--
-- Name: user PK_ea8f538c94b6e352418254ed6474a81f; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "PK_ea8f538c94b6e352418254ed6474a81f" PRIMARY KEY (id);


--
-- Name: insights_raw PK_ec15125755151e3a7e00e00014f; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.insights_raw
    ADD CONSTRAINT "PK_ec15125755151e3a7e00e00014f" PRIMARY KEY (id);


--
-- Name: chat_hub_agents PK_f39a3b36bbdf0e2979ddb21cf78; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_agents
    ADD CONSTRAINT "PK_f39a3b36bbdf0e2979ddb21cf78" PRIMARY KEY (id);


--
-- Name: insights_metadata PK_f448a94c35218b6208ce20cf5a1; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.insights_metadata
    ADD CONSTRAINT "PK_f448a94c35218b6208ce20cf5a1" PRIMARY KEY ("metaId");


--
-- Name: oauth_authorization_codes PK_fb91ab932cfbd694061501cc20f; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "PK_fb91ab932cfbd694061501cc20f" PRIMARY KEY (code);


--
-- Name: binary_data PK_fc3691585b39408bb0551122af6; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.binary_data
    ADD CONSTRAINT "PK_fc3691585b39408bb0551122af6" PRIMARY KEY ("fileId");


--
-- Name: role_scope PK_role_scope; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.role_scope
    ADD CONSTRAINT "PK_role_scope" PRIMARY KEY ("roleSlug", "scopeSlug");


--
-- Name: oauth_user_consents UQ_083721d99ce8db4033e2958ebb4; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "UQ_083721d99ce8db4033e2958ebb4" UNIQUE ("userId", "clientId");


--
-- Name: data_table_column UQ_8082ec4890f892f0bc77473a123; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.data_table_column
    ADD CONSTRAINT "UQ_8082ec4890f892f0bc77473a123" UNIQUE ("dataTableId", name);


--
-- Name: data_table UQ_b23096ef747281ac944d28e8b0d; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.data_table
    ADD CONSTRAINT "UQ_b23096ef747281ac944d28e8b0d" UNIQUE ("projectId", name);


--
-- Name: user UQ_e12875dfb3b1d92d7d7c5377e2; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "UQ_e12875dfb3b1d92d7d7c5377e2" UNIQUE (email);


--
-- Name: auth_identity auth_identity_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT auth_identity_pkey PRIMARY KEY ("providerId", "providerType");


--
-- Name: auth_provider_sync_history auth_provider_sync_history_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.auth_provider_sync_history
    ADD CONSTRAINT auth_provider_sync_history_pkey PRIMARY KEY (id);


--
-- Name: credentials_entity credentials_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.credentials_entity
    ADD CONSTRAINT credentials_entity_pkey PRIMARY KEY (id);


--
-- Name: event_destinations event_destinations_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.event_destinations
    ADD CONSTRAINT event_destinations_pkey PRIMARY KEY (id);


--
-- Name: execution_data execution_data_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_data
    ADD CONSTRAINT execution_data_pkey PRIMARY KEY ("executionId");


--
-- Name: execution_entity pk_e3e63bbf986767844bbe1166d4e; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_entity
    ADD CONSTRAINT pk_e3e63bbf986767844bbe1166d4e PRIMARY KEY (id);


--
-- Name: workflow_statistics pk_workflow_statistics; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_statistics
    ADD CONSTRAINT pk_workflow_statistics PRIMARY KEY ("workflowId", name);


--
-- Name: workflows_tags pk_workflows_tags; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflows_tags
    ADD CONSTRAINT pk_workflows_tags PRIMARY KEY ("workflowId", "tagId");


--
-- Name: tag_entity tag_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.tag_entity
    ADD CONSTRAINT tag_entity_pkey PRIMARY KEY (id);


--
-- Name: variables variables_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT variables_pkey PRIMARY KEY (id);


--
-- Name: workflow_entity workflow_entity_pkey; Type: CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_entity
    ADD CONSTRAINT workflow_entity_pkey PRIMARY KEY (id);


--
-- Name: IDX_070b5de842ece9ccdda0d9738b; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_070b5de842ece9ccdda0d9738b" ON public.workflow_publish_history USING btree ("workflowId", "versionId");


--
-- Name: IDX_14f68deffaf858465715995508; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX "IDX_14f68deffaf858465715995508" ON public.folder USING btree ("projectId", id);


--
-- Name: IDX_1d8ab99d5861c9388d2dc1cf73; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX "IDX_1d8ab99d5861c9388d2dc1cf73" ON public.insights_metadata USING btree ("workflowId");


--
-- Name: IDX_1e31657f5fe46816c34be7c1b4; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_1e31657f5fe46816c34be7c1b4" ON public.workflow_history USING btree ("workflowId");


--
-- Name: IDX_1ef35bac35d20bdae979d917a3; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX "IDX_1ef35bac35d20bdae979d917a3" ON public.user_api_keys USING btree ("apiKey");


--
-- Name: IDX_56900edc3cfd16612e2ef2c6a8; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_56900edc3cfd16612e2ef2c6a8" ON public.binary_data USING btree ("sourceType", "sourceId");


--
-- Name: IDX_5f0643f6717905a05164090dde; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_5f0643f6717905a05164090dde" ON public.project_relation USING btree ("userId");


--
-- Name: IDX_60b6a84299eeb3f671dfec7693; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX "IDX_60b6a84299eeb3f671dfec7693" ON public.insights_by_period USING btree ("periodStart", type, "periodUnit", "metaId");


--
-- Name: IDX_61448d56d61802b5dfde5cdb00; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_61448d56d61802b5dfde5cdb00" ON public.project_relation USING btree ("projectId");


--
-- Name: IDX_63d7bbae72c767cf162d459fcc; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX "IDX_63d7bbae72c767cf162d459fcc" ON public.user_api_keys USING btree ("userId", label);


--
-- Name: IDX_8e4b4774db42f1e6dda3452b2a; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_8e4b4774db42f1e6dda3452b2a" ON public.test_case_execution USING btree ("testRunId");


--
-- Name: IDX_97f863fa83c4786f1956508496; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX "IDX_97f863fa83c4786f1956508496" ON public.execution_annotations USING btree ("executionId");


--
-- Name: IDX_UniqueRoleDisplayName; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX "IDX_UniqueRoleDisplayName" ON public.role USING btree ("displayName");


--
-- Name: IDX_a3697779b366e131b2bbdae297; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_a3697779b366e131b2bbdae297" ON public.execution_annotation_tags USING btree ("tagId");


--
-- Name: IDX_a4ff2d9b9628ea988fa9e7d0bf; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_a4ff2d9b9628ea988fa9e7d0bf" ON public.workflow_dependency USING btree ("workflowId");


--
-- Name: IDX_ae51b54c4bb430cf92f48b623f; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX "IDX_ae51b54c4bb430cf92f48b623f" ON public.annotation_tag_entity USING btree (name);


--
-- Name: IDX_c1519757391996eb06064f0e7c; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_c1519757391996eb06064f0e7c" ON public.execution_annotation_tags USING btree ("annotationId");


--
-- Name: IDX_cec8eea3bf49551482ccb4933e; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX "IDX_cec8eea3bf49551482ccb4933e" ON public.execution_metadata USING btree ("executionId", key);


--
-- Name: IDX_d6870d3b6e4c185d33926f423c; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_d6870d3b6e4c185d33926f423c" ON public.test_run USING btree ("workflowId");


--
-- Name: IDX_e48a201071ab85d9d09119d640; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_e48a201071ab85d9d09119d640" ON public.workflow_dependency USING btree ("dependencyKey");


--
-- Name: IDX_e7fe1cfda990c14a445937d0b9; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_e7fe1cfda990c14a445937d0b9" ON public.workflow_dependency USING btree ("dependencyType");


--
-- Name: IDX_execution_entity_deletedAt; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_execution_entity_deletedAt" ON public.execution_entity USING btree ("deletedAt");


--
-- Name: IDX_role_scope_scopeSlug; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_role_scope_scopeSlug" ON public.role_scope USING btree ("scopeSlug");


--
-- Name: IDX_workflow_entity_name; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX "IDX_workflow_entity_name" ON public.workflow_entity USING btree (name);


--
-- Name: idx_07fde106c0b471d8cc80a64fc8; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX idx_07fde106c0b471d8cc80a64fc8 ON public.credentials_entity USING btree (type);


--
-- Name: idx_16f4436789e804e3e1c9eeb240; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX idx_16f4436789e804e3e1c9eeb240 ON public.webhook_entity USING btree ("webhookId", method, "pathLength");


--
-- Name: idx_812eb05f7451ca757fb98444ce; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX idx_812eb05f7451ca757fb98444ce ON public.tag_entity USING btree (name);


--
-- Name: idx_execution_entity_stopped_at_status_deleted_at; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX idx_execution_entity_stopped_at_status_deleted_at ON public.execution_entity USING btree ("stoppedAt", status, "deletedAt") WHERE (("stoppedAt" IS NOT NULL) AND ("deletedAt" IS NULL));


--
-- Name: idx_execution_entity_wait_till_status_deleted_at; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX idx_execution_entity_wait_till_status_deleted_at ON public.execution_entity USING btree ("waitTill", status, "deletedAt") WHERE (("waitTill" IS NOT NULL) AND ("deletedAt" IS NULL));


--
-- Name: idx_execution_entity_workflow_id_started_at; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX idx_execution_entity_workflow_id_started_at ON public.execution_entity USING btree ("workflowId", "startedAt") WHERE (("startedAt" IS NOT NULL) AND ("deletedAt" IS NULL));


--
-- Name: idx_workflows_tags_workflow_id; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX idx_workflows_tags_workflow_id ON public.workflows_tags USING btree ("workflowId");


--
-- Name: pk_credentials_entity_id; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX pk_credentials_entity_id ON public.credentials_entity USING btree (id);


--
-- Name: pk_tag_entity_id; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX pk_tag_entity_id ON public.tag_entity USING btree (id);


--
-- Name: pk_workflow_entity_id; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX pk_workflow_entity_id ON public.workflow_entity USING btree (id);


--
-- Name: project_relation_role_idx; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX project_relation_role_idx ON public.project_relation USING btree (role);


--
-- Name: project_relation_role_project_idx; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX project_relation_role_project_idx ON public.project_relation USING btree ("projectId", role);


--
-- Name: user_role_idx; Type: INDEX; Schema: public; Owner: n8n
--

CREATE INDEX user_role_idx ON public."user" USING btree ("roleSlug");


--
-- Name: variables_global_key_unique; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX variables_global_key_unique ON public.variables USING btree (key) WHERE ("projectId" IS NULL);


--
-- Name: variables_project_key_unique; Type: INDEX; Schema: public; Owner: n8n
--

CREATE UNIQUE INDEX variables_project_key_unique ON public.variables USING btree ("projectId", key) WHERE ("projectId" IS NOT NULL);


--
-- Name: workflow_entity workflow_version_increment; Type: TRIGGER; Schema: public; Owner: n8n
--

CREATE TRIGGER workflow_version_increment BEFORE UPDATE ON public.workflow_entity FOR EACH ROW EXECUTE FUNCTION public.increment_workflow_version();


--
-- Name: processed_data FK_06a69a7032c97a763c2c7599464; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.processed_data
    ADD CONSTRAINT "FK_06a69a7032c97a763c2c7599464" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: workflow_entity FK_08d6c67b7f722b0039d9d5ed620; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_entity
    ADD CONSTRAINT "FK_08d6c67b7f722b0039d9d5ed620" FOREIGN KEY ("activeVersionId") REFERENCES public.workflow_history("versionId") ON DELETE RESTRICT;


--
-- Name: insights_metadata FK_1d8ab99d5861c9388d2dc1cf733; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.insights_metadata
    ADD CONSTRAINT "FK_1d8ab99d5861c9388d2dc1cf733" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE SET NULL;


--
-- Name: workflow_history FK_1e31657f5fe46816c34be7c1b4b; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_history
    ADD CONSTRAINT "FK_1e31657f5fe46816c34be7c1b4b" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_1f4998c8a7dec9e00a9ab15550e; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_1f4998c8a7dec9e00a9ab15550e" FOREIGN KEY ("revisionOfMessageId") REFERENCES public.chat_hub_messages(id) ON DELETE CASCADE;


--
-- Name: oauth_user_consents FK_21e6c3c2d78a097478fae6aaefa; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "FK_21e6c3c2d78a097478fae6aaefa" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: insights_metadata FK_2375a1eda085adb16b24615b69c; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.insights_metadata
    ADD CONSTRAINT "FK_2375a1eda085adb16b24615b69c" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE SET NULL;


--
-- Name: chat_hub_messages FK_25c9736e7f769f3a005eef4b372; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_25c9736e7f769f3a005eef4b372" FOREIGN KEY ("retryOfMessageId") REFERENCES public.chat_hub_messages(id) ON DELETE CASCADE;


--
-- Name: execution_metadata FK_31d0b4c93fb85ced26f6005cda3; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_metadata
    ADD CONSTRAINT "FK_31d0b4c93fb85ced26f6005cda3" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE CASCADE;


--
-- Name: shared_credentials FK_416f66fc846c7c442970c094ccf; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.shared_credentials
    ADD CONSTRAINT "FK_416f66fc846c7c442970c094ccf" FOREIGN KEY ("credentialsId") REFERENCES public.credentials_entity(id) ON DELETE CASCADE;


--
-- Name: variables FK_42f6c766f9f9d2edcc15bdd6e9b; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.variables
    ADD CONSTRAINT "FK_42f6c766f9f9d2edcc15bdd6e9b" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: chat_hub_agents FK_441ba2caba11e077ce3fbfa2cd8; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_agents
    ADD CONSTRAINT "FK_441ba2caba11e077ce3fbfa2cd8" FOREIGN KEY ("ownerId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: project_relation FK_5f0643f6717905a05164090dde7; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "FK_5f0643f6717905a05164090dde7" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: project_relation FK_61448d56d61802b5dfde5cdb002; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "FK_61448d56d61802b5dfde5cdb002" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: insights_by_period FK_6414cfed98daabbfdd61a1cfbc0; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.insights_by_period
    ADD CONSTRAINT "FK_6414cfed98daabbfdd61a1cfbc0" FOREIGN KEY ("metaId") REFERENCES public.insights_metadata("metaId") ON DELETE CASCADE;


--
-- Name: oauth_authorization_codes FK_64d965bd072ea24fb6da55468cd; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "FK_64d965bd072ea24fb6da55468cd" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_6afb260449dd7a9b85355d4e0c9; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_6afb260449dd7a9b85355d4e0c9" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE SET NULL;


--
-- Name: insights_raw FK_6e2e33741adef2a7c5d66befa4e; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.insights_raw
    ADD CONSTRAINT "FK_6e2e33741adef2a7c5d66befa4e" FOREIGN KEY ("metaId") REFERENCES public.insights_metadata("metaId") ON DELETE CASCADE;


--
-- Name: workflow_publish_history FK_6eab5bd9eedabe9c54bd879fc40; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_publish_history
    ADD CONSTRAINT "FK_6eab5bd9eedabe9c54bd879fc40" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE SET NULL;


--
-- Name: oauth_access_tokens FK_7234a36d8e49a1fa85095328845; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT "FK_7234a36d8e49a1fa85095328845" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: installed_nodes FK_73f857fc5dce682cef8a99c11dbddbc969618951; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.installed_nodes
    ADD CONSTRAINT "FK_73f857fc5dce682cef8a99c11dbddbc969618951" FOREIGN KEY (package) REFERENCES public.installed_packages("packageName") ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: oauth_access_tokens FK_78b26968132b7e5e45b75876481; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_access_tokens
    ADD CONSTRAINT "FK_78b26968132b7e5e45b75876481" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: chat_hub_sessions FK_7bc13b4c7e6afbfaf9be326c189; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "FK_7bc13b4c7e6afbfaf9be326c189" FOREIGN KEY ("credentialId") REFERENCES public.credentials_entity(id) ON DELETE SET NULL;


--
-- Name: folder FK_804ea52f6729e3940498bd54d78; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT "FK_804ea52f6729e3940498bd54d78" FOREIGN KEY ("parentFolderId") REFERENCES public.folder(id) ON DELETE CASCADE;


--
-- Name: shared_credentials FK_812c2852270da1247756e77f5a4; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.shared_credentials
    ADD CONSTRAINT "FK_812c2852270da1247756e77f5a4" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: test_case_execution FK_8e4b4774db42f1e6dda3452b2af; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.test_case_execution
    ADD CONSTRAINT "FK_8e4b4774db42f1e6dda3452b2af" FOREIGN KEY ("testRunId") REFERENCES public.test_run(id) ON DELETE CASCADE;


--
-- Name: data_table_column FK_930b6e8faaf88294cef23484160; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.data_table_column
    ADD CONSTRAINT "FK_930b6e8faaf88294cef23484160" FOREIGN KEY ("dataTableId") REFERENCES public.data_table(id) ON DELETE CASCADE;


--
-- Name: folder_tag FK_94a60854e06f2897b2e0d39edba; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.folder_tag
    ADD CONSTRAINT "FK_94a60854e06f2897b2e0d39edba" FOREIGN KEY ("folderId") REFERENCES public.folder(id) ON DELETE CASCADE;


--
-- Name: execution_annotations FK_97f863fa83c4786f19565084960; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_annotations
    ADD CONSTRAINT "FK_97f863fa83c4786f19565084960" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE CASCADE;


--
-- Name: chat_hub_agents FK_9c61ad497dcbae499c96a6a78ba; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_agents
    ADD CONSTRAINT "FK_9c61ad497dcbae499c96a6a78ba" FOREIGN KEY ("credentialId") REFERENCES public.credentials_entity(id) ON DELETE SET NULL;


--
-- Name: chat_hub_sessions FK_9f9293d9f552496c40e0d1a8f80; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "FK_9f9293d9f552496c40e0d1a8f80" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE SET NULL;


--
-- Name: execution_annotation_tags FK_a3697779b366e131b2bbdae2976; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_annotation_tags
    ADD CONSTRAINT "FK_a3697779b366e131b2bbdae2976" FOREIGN KEY ("tagId") REFERENCES public.annotation_tag_entity(id) ON DELETE CASCADE;


--
-- Name: shared_workflow FK_a45ea5f27bcfdc21af9b4188560; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.shared_workflow
    ADD CONSTRAINT "FK_a45ea5f27bcfdc21af9b4188560" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: workflow_dependency FK_a4ff2d9b9628ea988fa9e7d0bf8; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_dependency
    ADD CONSTRAINT "FK_a4ff2d9b9628ea988fa9e7d0bf8" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: oauth_user_consents FK_a651acea2f6c97f8c4514935486; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_user_consents
    ADD CONSTRAINT "FK_a651acea2f6c97f8c4514935486" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: oauth_refresh_tokens FK_a699f3ed9fd0c1b19bc2608ac53; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_refresh_tokens
    ADD CONSTRAINT "FK_a699f3ed9fd0c1b19bc2608ac53" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: folder FK_a8260b0b36939c6247f385b8221; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.folder
    ADD CONSTRAINT "FK_a8260b0b36939c6247f385b8221" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: oauth_authorization_codes FK_aa8d3560484944c19bdf79ffa16; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_authorization_codes
    ADD CONSTRAINT "FK_aa8d3560484944c19bdf79ffa16" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_acf8926098f063cdbbad8497fd1; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_acf8926098f063cdbbad8497fd1" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE SET NULL;


--
-- Name: oauth_refresh_tokens FK_b388696ce4d8be7ffbe8d3e4b69; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.oauth_refresh_tokens
    ADD CONSTRAINT "FK_b388696ce4d8be7ffbe8d3e4b69" FOREIGN KEY ("clientId") REFERENCES public.oauth_clients(id) ON DELETE CASCADE;


--
-- Name: workflow_publish_history FK_b4cfbc7556d07f36ca177f5e473; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_publish_history
    ADD CONSTRAINT "FK_b4cfbc7556d07f36ca177f5e473" FOREIGN KEY ("versionId") REFERENCES public.workflow_history("versionId") ON DELETE CASCADE;


--
-- Name: workflow_publish_history FK_c01316f8c2d7101ec4fa9809267; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_publish_history
    ADD CONSTRAINT "FK_c01316f8c2d7101ec4fa9809267" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: execution_annotation_tags FK_c1519757391996eb06064f0e7c8; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_annotation_tags
    ADD CONSTRAINT "FK_c1519757391996eb06064f0e7c8" FOREIGN KEY ("annotationId") REFERENCES public.execution_annotations(id) ON DELETE CASCADE;


--
-- Name: data_table FK_c2a794257dee48af7c9abf681de; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.data_table
    ADD CONSTRAINT "FK_c2a794257dee48af7c9abf681de" FOREIGN KEY ("projectId") REFERENCES public.project(id) ON DELETE CASCADE;


--
-- Name: project_relation FK_c6b99592dc96b0d836d7a21db91; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.project_relation
    ADD CONSTRAINT "FK_c6b99592dc96b0d836d7a21db91" FOREIGN KEY (role) REFERENCES public.role(slug);


--
-- Name: test_run FK_d6870d3b6e4c185d33926f423c8; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.test_run
    ADD CONSTRAINT "FK_d6870d3b6e4c185d33926f423c8" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: shared_workflow FK_daa206a04983d47d0a9c34649ce; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.shared_workflow
    ADD CONSTRAINT "FK_daa206a04983d47d0a9c34649ce" FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: folder_tag FK_dc88164176283de80af47621746; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.folder_tag
    ADD CONSTRAINT "FK_dc88164176283de80af47621746" FOREIGN KEY ("tagId") REFERENCES public.tag_entity(id) ON DELETE CASCADE;


--
-- Name: user_api_keys FK_e131705cbbc8fb589889b02d457; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.user_api_keys
    ADD CONSTRAINT "FK_e131705cbbc8fb589889b02d457" FOREIGN KEY ("userId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: chat_hub_messages FK_e22538eb50a71a17954cd7e076c; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_e22538eb50a71a17954cd7e076c" FOREIGN KEY ("sessionId") REFERENCES public.chat_hub_sessions(id) ON DELETE CASCADE;


--
-- Name: test_case_execution FK_e48965fac35d0f5b9e7f51d8c44; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.test_case_execution
    ADD CONSTRAINT "FK_e48965fac35d0f5b9e7f51d8c44" FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE SET NULL;


--
-- Name: chat_hub_messages FK_e5d1fa722c5a8d38ac204746662; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_messages
    ADD CONSTRAINT "FK_e5d1fa722c5a8d38ac204746662" FOREIGN KEY ("previousMessageId") REFERENCES public.chat_hub_messages(id) ON DELETE CASCADE;


--
-- Name: chat_hub_sessions FK_e9ecf8ede7d989fcd18790fe36a; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.chat_hub_sessions
    ADD CONSTRAINT "FK_e9ecf8ede7d989fcd18790fe36a" FOREIGN KEY ("ownerId") REFERENCES public."user"(id) ON DELETE CASCADE;


--
-- Name: user FK_eaea92ee7bfb9c1b6cd01505d56; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT "FK_eaea92ee7bfb9c1b6cd01505d56" FOREIGN KEY ("roleSlug") REFERENCES public.role(slug);


--
-- Name: role_scope FK_role; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.role_scope
    ADD CONSTRAINT "FK_role" FOREIGN KEY ("roleSlug") REFERENCES public.role(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: role_scope FK_scope; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.role_scope
    ADD CONSTRAINT "FK_scope" FOREIGN KEY ("scopeSlug") REFERENCES public.scope(slug) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: auth_identity auth_identity_userId_fkey; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.auth_identity
    ADD CONSTRAINT "auth_identity_userId_fkey" FOREIGN KEY ("userId") REFERENCES public."user"(id);


--
-- Name: execution_data execution_data_fk; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_data
    ADD CONSTRAINT execution_data_fk FOREIGN KEY ("executionId") REFERENCES public.execution_entity(id) ON DELETE CASCADE;


--
-- Name: execution_entity fk_execution_entity_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.execution_entity
    ADD CONSTRAINT fk_execution_entity_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: webhook_entity fk_webhook_entity_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.webhook_entity
    ADD CONSTRAINT fk_webhook_entity_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: workflow_entity fk_workflow_parent_folder; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_entity
    ADD CONSTRAINT fk_workflow_parent_folder FOREIGN KEY ("parentFolderId") REFERENCES public.folder(id) ON DELETE CASCADE;


--
-- Name: workflow_statistics fk_workflow_statistics_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflow_statistics
    ADD CONSTRAINT fk_workflow_statistics_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- Name: workflows_tags fk_workflows_tags_tag_id; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflows_tags
    ADD CONSTRAINT fk_workflows_tags_tag_id FOREIGN KEY ("tagId") REFERENCES public.tag_entity(id) ON DELETE CASCADE;


--
-- Name: workflows_tags fk_workflows_tags_workflow_id; Type: FK CONSTRAINT; Schema: public; Owner: n8n
--

ALTER TABLE ONLY public.workflows_tags
    ADD CONSTRAINT fk_workflows_tags_workflow_id FOREIGN KEY ("workflowId") REFERENCES public.workflow_entity(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict 9r8SDNEF3KzTYPhUwYLih07FWBnqRER44CkNmawm13Wj3ju4QKEqdISbyjLfk7T

