package com.javarush.jira.profile.internal.web;

import com.javarush.jira.AbstractControllerTest;
import com.javarush.jira.common.util.JsonUtil;
import org.junit.jupiter.api.Test;
import org.springframework.http.MediaType;
import org.springframework.security.test.context.support.WithUserDetails;

import static com.javarush.jira.login.internal.web.UserTestData.*;
import static com.javarush.jira.profile.internal.web.ProfileRestController.REST_URL;
import static com.javarush.jira.profile.internal.web.ProfileTestData.*;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.*;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

class ProfileRestControllerTest extends AbstractControllerTest {


    @Test
    @WithUserDetails(value = USER_MAIL)
    void getUserProfileTest() throws Exception {
        USER_PROFILE_TO.setId(USER_ID);
        perform(get(REST_URL))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(PROFILE_TO_MATCHER.contentJson(USER_PROFILE_TO));
    }

    @Test
    @WithUserDetails(value = GUEST_MAIL)
    void getGuestProfileTest() throws Exception {
        GUEST_PROFILE_EMPTY_TO.setId(GUEST_ID);
        perform(get(REST_URL))
                .andExpect(status().isOk())
                .andExpect(content().contentTypeCompatibleWith(MediaType.APPLICATION_JSON))
                .andExpect(PROFILE_TO_MATCHER.contentJson(GUEST_PROFILE_EMPTY_TO));
    }

    @Test
    void getUnAuthorizedTest() throws Exception {
        perform(get(REST_URL))
                .andExpect(status().isUnauthorized());
    }

    @Test
    void updateUnAuthorizedTest() throws Exception {
        perform(put(REST_URL).contentType(MediaType.APPLICATION_JSON))
                .andExpect(status().isUnauthorized());
    }

    @Test
    @WithUserDetails(USER_MAIL)
    void updateTestSuccessfulTest() throws Exception {
        perform(put(REST_URL)
                .contentType(MediaType.APPLICATION_JSON)
                .content(JsonUtil.writeValue(getNewTo())))
                .andExpect(status().isNoContent());

    }

    @Test
    @WithUserDetails(USER_MAIL)
    void updateInvalidToTest() throws Exception {
        perform(put(REST_URL)
                .contentType(MediaType.APPLICATION_JSON)
                .content(JsonUtil.writeValue(getInvalidTo())))
                .andExpect(status().isUnprocessableEntity());
    }

    @Test
    @WithUserDetails(USER_MAIL)
    void updateWithUnknownNotificationTest() throws Exception {
        perform(put(REST_URL)
                .contentType(MediaType.APPLICATION_JSON)
                .content(JsonUtil.writeValue(getWithUnknownNotificationTo())))
                .andExpect(status().isUnprocessableEntity());
    }

    @Test
    @WithUserDetails(USER_MAIL)
    void updateWithUnknownContactTest() throws Exception {
        perform(put(REST_URL)
                .contentType(MediaType.APPLICATION_JSON)
                .content(JsonUtil.writeValue(getWithUnknownContactTo())))
                .andExpect(status().isUnprocessableEntity());
    }

    @Test
    @WithUserDetails(USER_MAIL)
    void updateWithContactHtmlUnsafeTest() throws Exception {
        perform(put(REST_URL)
                .contentType(MediaType.APPLICATION_JSON)
                .content(JsonUtil.writeValue(getWithContactHtmlUnsafeTo())))
                .andExpect(status().isUnprocessableEntity());
    }
}