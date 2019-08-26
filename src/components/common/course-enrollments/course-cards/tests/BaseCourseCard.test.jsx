import React from 'react';
import { mount } from 'enzyme';
import thunk from 'redux-thunk';
import { Provider } from 'react-redux';
import configureMockStore from 'redux-mock-store';
import * as analytics from '@edx/frontend-analytics';

import { LayoutContext } from '../../../layout';
import BaseCourseCard from '../BaseCourseCard';

const mockStore = configureMockStore([thunk]);
const store = mockStore({
  userAccount: {
    username: 'edx',
  },
});

describe('<BaseCourseCard />', () => {
  describe('email settings modal', () => {
    let wrapper;
    analytics.sendTrackEvent = jest.fn();

    beforeEach(() => {
      const pageContext = {
        pageType: 'pages.EnterprisePage',
      };
      wrapper = mount((
        <Provider store={store}>
          <LayoutContext.Provider value={{ pageContext }}>
            <BaseCourseCard
              title="edX Demonstration Course"
              linkToCourse="https://edx.org"
              courseRunId="my+course+key"
              hasEmailsEnabled
            />
          </LayoutContext.Provider>
        </Provider>
      ));
      // open email settings modal
      wrapper.find('Dropdown').find('button.dropdown-toggle').simulate('click');
      wrapper.find('Dropdown').find('button.dropdown-item').simulate('click');
      expect(wrapper.find('BaseCourseCard').state('modals').emailSettings.open).toBeTruthy();
    });

    it('test modal close/cancel', () => {
      wrapper.find('EmailSettingsModal').find('.modal-footer .js-close-modal-on-click').first().simulate('click');
      expect(wrapper.find('BaseCourseCard').state('modals').emailSettings.open).toBeFalsy();
    });
  });
});
